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
 )

(provide (all-defined-out))


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

(define/contract (hash-key-set-subtract hsh key lst)
  (-> (and/c hash? immutable?) any/c list?
      (and/c hash? immutable?))
  "Execute `set-subtract', taking LST as second argument, on the KEY of HSH."
  (hash-update hsh key (lambda (ds) (set-subtract ds lst)) '())
  )
