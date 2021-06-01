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
 "all.rkt"
 "filter.rkt"
 )

(provide
 pkgs-hash
 )


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

(define pkgs#platformed
  (filter pkg-for-arch? (hash-keys all-pkgs-hash))
  )


(define (hash-remove-main-distribution hsh)
  (hash-purge-pkgs hsh pkgs#main-distribution)
  )

(define (hash-remove-platformed hsh)
  (hash-purge-pkgs hsh pkgs#platformed)
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
