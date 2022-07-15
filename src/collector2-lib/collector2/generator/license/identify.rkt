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
;; Copyright (c) 2021-2022, src_prepare group
;; Licensed under the GNU GPL v3 License
;; SPDX-License-Identifier: GPL-3.0-only


#lang racket/base

(require
 racket/match
 threading)

(provide (all-defined-out))


(define (SPDX->Gentoo license-symbol)
  (let ([license-string (symbol->string license-symbol)])
    (cond
      [(regexp-match "GPL" license-string)
       (~> license-string
           (regexp-replace ".0" _ "")
           (regexp-replace "-only" _ "")
           (regexp-replace "-or-later" _ "+"))]
      [(regexp-match "BSD" license-string)
       (regexp-replace "-Clause" license-string "")]
      [else
       license-string])))

(define (identify-license license-expr)
  (match license-expr
    [(list lhs 'OR rhs)
     (format "|| ( ~a ~a )" (identify-license lhs) (identify-license rhs))]
    [(list lhs (or 'AND 'WITH) rhs)
     (format "~a ~a" (identify-license lhs) (identify-license rhs))]
    [sym  ; (? symbol? sym)
     (SPDX->Gentoo sym)]))
