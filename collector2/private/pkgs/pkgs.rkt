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
 racket/string
 "all.rkt"
 )

(provide
 pkgs-hash
 )


;; CONSIDER: Or maybe just skip missing dependencies?
;; CONSIDER: `hash-update-each' functions


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

(define/contract (hash-filter procedure hsh)
  (-> (-> any/c any/c) (and/c hash? immutable?)
      (and/c hash? immutable?))
  (hash-remove-keys
   hsh
   (filter (lambda (key) (not (procedure (hash-ref hsh key))))
           (hash-keys hsh))
   )
  )
;; (hash-filter hash? test-hash)
;; (hash-filter (λ (h) (string-contains? (car (hash-ref h 'tags '(""))) "main")) test-hash)

;; With mutable hash:
;; (define/contract (hash-remove-keys! hsh lst)
;;   (-> (and/c hash? (not/c immutable?)) list? void)
;;   (for ([key lst])
;;     (hash-remove! hsh key)
;;     )
;;   )
;; (hash-remove-keys! all-pkgs-hash pkgs#main-distribution)

#| Test: `filter-tag'
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


(define arches
  '(
    "aarch64"
    "i386"
    "linux-natipkg"
    "ppc"
    "win32"
    "x86-64"
    "x86_64"
    ))

;; FIXME: better implementation of `pkg-for-arch?'

(define/contract (pkg-for-arch? pkg)
  (-> string? boolean?)
  "Check if a PKG is meant for a specific platform."
  (set-member?
   (map (lambda (s) (string-contains? pkg (string-append "-" s)))
        arches)
   #t
   )
  )

(define pkgs#platformed
  (filter pkg-for-arch? (hash-keys all-pkgs-hash))
  )


(define/contract (hash-key-set-subtract hsh key lst)
  (-> (and/c hash? immutable?) any/c list?
      (and/c hash? immutable?))
  "Execute `set-subtract', taking LST as second argument, on the KEY of HSH."
  (hash-update hsh key (lambda (ds) (set-subtract ds lst)) '())
  )

(define/contract (hash-remove-dependencies hsh lst deps)
  (-> (and/c hash? immutable?) list? list?
      (and/c hash? immutable?))
  "Create a hash from HSH where values of keys from LST have DEPS subtracted."
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

(define/contract (hash-purge-pkgs hsh lst)
  (-> (and/c hash? immutable?) (listof string?)
      (and/c hash? immutable?))
  "Create a hash from HSH where packages matching a package name from LST
   are removed from the HSH hash and from the dependencies list of
   remaining packages."
  (let*
      (
       [h  (hash-remove-keys hsh lst)]
       [hk (hash-keys h)]
       )
    (hash-remove-dependencies h hk lst)
    )
  )

;; "weak" - we don't check #:version or any other special conditions
(define/contract (dependency-exists v pkgs)
  (-> (or/c list? string?) (listof string?)
      boolean?)
  "Check if V exist in PKGS."
  (cond
    [(list? v)   (set-member? pkgs (car v))]
    [(string? v) (set-member? pkgs v)]
    )
  )
;; (dependency-exists "base" (hash-keys all-pkgs-hash))

(define/contract (missing-dependencies hsh)
  (-> (and/c hash? immutable?) list?)
  "Given HSH return a list of dependencies that do not exist in it."
  (let
      ([md '()])
    (for
        ([data (hash-values hsh)])
      (for
          ([dep (hash-ref data 'dependencies '())])
        (when (not (dependency-exists dep (hash-keys hsh)))
          (set! md (append md (list dep))))
        )
      )
    md
    )
  )
#| Check dependencies that list pkgs from main-distribution
(missing-dependencies (hash-remove-main-distribution all-pkgs-hash))
|#

(define/contract (hash-remove-missing-dependencies hsh)
  (-> (and/c hash? immutable?) (and/c hash? immutable?))
  (hash-remove-dependencies hsh (hash-keys hsh) (missing-dependencies hsh))
  )


(define (hash-remove-main-distribution hsh)
  (hash-purge-pkgs hsh pkgs#main-distribution)
  )

(define (hash-remove-platformed hsh)
  (hash-purge-pkgs hsh pkgs#platformed)
  )


(define/contract (hash-filter-source hsh str)
  (-> (and/c hash? immutable?) string?
      (and/c hash? immutable?))
  (hash-filter
   (lambda (h) (string-contains? (hash-ref h 'source "") str))
   hsh
   )
  )


(define pkgs-hash
  (hash-remove-missing-dependencies
   (hash-remove-platformed
    (hash-remove-main-distribution
     (hash-filter-source all-pkgs-hash "git")
     )
    )
   )
  )
