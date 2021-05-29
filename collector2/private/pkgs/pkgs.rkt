#!/usr/bin/env racket


;; This file is part of collector2.

;; collector2 is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, version 3.

;; collector2 is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with collector2.  If not, see <https://www.gnu.org/licenses/>.

;; Original author: Maciej Barć <xgqt@riseup.net>
;; Copyright (c) 2021, src_prepare group
;; Licensed under the GNU GPL v3 License
;; SPDX-License-Identifier: GPL-3.0-only


#lang racket/base

(require
 racket/contract
 racket/set
 "all.rkt"
 )

(provide
 pkgs-hash
 )


;; 1st: gather all pkgs that have tag main dist   - pkgs#main-distribution
;; 2nd: filter them from the hash                 - filter:main-dist
;; 3rd: filter them from dependencies             - filter-data:main-dist

;; CONSIDER: Or maybe just skip missing dependencies?


(define/contract (filter-tag tag hsh)
  (-> string? hash? (listof string?))
  "Produce a list from HSH containing only packages with a matching TAG."
  (filter string?
          (hash-map hsh
                    (lambda (name data)
                      (if (member tag (hash-ref data 'tags '()))
                          name
                          #f
                          )
                      )
                    )
          )
  )

(define/contract (hash-remove-keys hsh lst)
  (-> (and/c hash? immutable?) list? (and/c hash? immutable?))
  "Produce a hash from HSH with keys included in LST removed."
  (cond
    [(null? lst)  hsh]
    [else  (hash-remove-keys (hash-remove hsh (car lst)) (cdr lst))]
    )
  )

;; With mutable hash:
;; (define/contract (hash-remove-keys! hsh lst)
;;   (-> (and/c hash? (not/c immutable?)) list? void)
;;   (for ([key lst])
;;     (hash-remove! hsh key)
;;     )
;;   )
;; (hash-remove-keys! all-pkgs-hash pkgs#main-distribution)

#|
;; Test: `filter-tag'
(define test-hash #hash(["base"     . #hash([tags . ("main-distribution")])]
                        ["scribble" . #hash([tags . ("main-distribution")])]
                        ["custom0"  . #hash([tags . ("main-distribution")])]
                        ["custom1"  . #hash()]
                        ["custom2"  . #hash([dependencies . ("base" "custom1")])]
                        ))
(filter-tag "main-distribution" test-hsh)
(hash-update test-hash "custom1" (lambda (_) (list)))
(hash-update (hash-ref test-hash "custom2")
             'dependencies (lambda (ds) (set-subtract ds '("base"))))
(hash-key-set-subtract (hash-ref test-hash "custom2") 'dependencies '("base"))
(hash-remove-dependencies test-hash (hash-keys test-hash) '("base"))
|#

(define pkgs#main-distribution (filter-tag "main-distribution" all-pkgs-hash))

(define/contract (hash-key-set-subtract hsh key lst)
  (-> (and/c hash? immutable?) any/c (listof string?)
      (and/c hash? immutable?))
  "Execute `set-subtract', taking LST as second argument on the KEY of HSH."
  (hash-update hsh key (λ (ds) (set-subtract ds lst)) '())
  )

(define/contract (hash-remove-dependencies hsh lst deps)
  (-> (and/c hash? immutable?) list? (listof string?)
      (and/c hash? immutable?))
  "Create a hash from HSH where keys from LST have DEPS subtracted."
  (cond
    [(null? lst)  hsh]
    [else  (hash-remove-dependencies
            (hash-update
             hsh (car lst)
             (lambda (h) (hash-key-set-subtract h 'dependencies deps))
             )
            (cdr lst)
            deps
            )]
    )
  )

(define (hash-remove-main-distribution hsh)
  (let*
      (
       [h  (hash-remove-keys hsh pkgs#main-distribution)]
       [hk (hash-keys h)]
       )
    (hash-remove-dependencies h hk pkgs#main-distribution)
    )
  )


(define pkgs-hash (hash-remove-main-distribution all-pkgs-hash))
