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

(provide (all-defined-out))


(define (counter [start-val 0])
  (define val start-val)
  (lambda ()
    (set! val (+ 1 val))
    ;; convert to string just because it is common
    ;; in this project to do `string-append'
    (number->string val)
    )
  )


(module+ test
  (require rackunit)

  (define c0 (counter))
  (define c1 (counter))
  (define c2 (counter 777))
  (void
   (c1) (c1)
   (c2) (c2) (c2)
   )

  (check-true (procedure? counter))
  (check-true (procedure? c0))
  (check-equal? (c0) "1")
  (check-equal? (c1) "3")
  (check-equal? (c2) "781")
  )
