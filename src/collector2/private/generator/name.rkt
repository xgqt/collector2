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
 racket/string
 )

(provide make-valid-name)


;; asd-9 is a invalid name
;; WORKAROUND: asd-9 -> asd9
(define (make-valid-name name)
  (let ([mname name]
        [invalid-numbers (regexp-match* #rx"-[0-9]" name)])
    (for ([in invalid-numbers])
      ;; FIXME: regex ?
      (set! mname (string-replace mname in (string-trim in "-")))
      )
    (string-downcase mname)
    ))
