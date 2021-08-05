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
 "filter.rkt"
 "hash.rkt"
 )


(define test-hash
  #hash(
        ["custom0"  . #hash([source       . "https://gitlab.com/asd/custom0.git"])]
        ["custom1"  . #hash([tags         . ("main-distribution")])]
        ["custom2"  . #hash([dependencies . ("custom0" "custom1")]
                            [tags         . ("main-distribution")])]
        ["custom3"  . #hash([dependencies . ("custom2")])]
        ["custom4"  . #hash([dependencies . ("custom3")])]
        ["custom5"  . #hash([dependencies . ("custom0" "custom5" "none")])]
        )
  )

(define (numkeys hsh)
  (length (hash-keys hsh))
  )


(module+ test
  (require rackunit)

  (check-eq?  (numkeys (hash-remove-keys test-hash '()))  6)
  (check-eq?  (numkeys (hash-remove-keys test-hash '("custom0")))  5)
  (check-eq?
   (numkeys (hash-remove-keys test-hash '("custom0" "custom1" "custom2")))  3)

  (check-eq?  (numkeys (hash-filter list? test-hash))  0)
  (check-eq?  (numkeys (hash-filter hash? test-hash))  6)
  (check-eq?
   (numkeys (hash-filter
             (lambda (h) (equal? (car (hash-ref h 'tags '(""))) "main-distribution"))
             test-hash))
   2)

  (check-equal?
   (length (hash-ref
            (hash-key-set-subtract (hash-ref test-hash "custom5")
                                   'dependencies '("custom0")) 'dependencies))
   2)

  (check-eq?  (length (filter-tag "" test-hash))  0)
  (check-eq?  (length (filter-tag "main-distribution" test-hash))  2)

  (check-equal?  (numkeys (hash-filter-source test-hash #rx".*"))  6)
  (check-equal?  (numkeys (hash-filter-source test-hash #rx".*gitlab.*"))  1)

  (check-eq?  (numkeys (hash-purge-pkgs test-hash '()))  6)
  (check-eq?
   (numkeys (hash-purge-pkgs test-hash '("custom0" "custom1" "custom2")))
   3)
  (check-eq?  (numkeys (hash-purge-pkgs test-hash (hash-keys test-hash)))  0)

  (check-eq?
   (length (hash-ref (hash-ref (hash-remove-missing-dependencies test-hash)
                               "custom5") 'dependencies))
   2)

  (check-false  (pkg-for-arch? ""))
  (check-false  (pkg-for-arch? "aarch64"))
  (check-true  (pkg-for-arch? "asd-aarch64"))
  )
