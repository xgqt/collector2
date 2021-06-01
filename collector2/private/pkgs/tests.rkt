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
        ["custom0"  . #hash()]
        ["custom1"  . #hash([tags         . ("main-distribution")])]
        ["custom2"  . #hash([dependencies . ("custom0" "custom1")]
                            [tags         . ("main-distribution")])]
        ["custom3"  . #hash([dependencies . ("custom2")])]
        ["custom4"  . #hash([dependencies . ("custom3")])]
        ["custom5"  . #hash([dependencies . ("custom0" "custom5")])]
        )
  )

(define (numkeys hsh)
  (length (hash-keys hsh))
  )


(module+ test
  (require rackunit)

  (check-equal?  (numkeys (hash-remove-keys test-hash '()))  6)
  (check-equal?  (numkeys (hash-remove-keys test-hash '("custom0")))  5)
  (check-equal?
   (numkeys (hash-remove-keys test-hash '("custom0" "custom1" "custom2")))  3)

  (check-equal?  (numkeys (hash-filter list? test-hash))  0)
  (check-equal?  (numkeys (hash-filter hash? test-hash))  6)
  (check-equal?
   (numkeys (hash-filter
             (λ (h) (equal? (car (hash-ref h 'tags '(""))) "main-distribution"))
             test-hash))
   2)

  (check-equal?
   (hash-key-set-subtract
    (hash-ref test-hash "custom5") 'dependencies '("custom0"))
   #hash([dependencies . ("custom5")])
   )
  )
