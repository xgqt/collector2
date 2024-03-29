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
 pkg/lib)

(provide all-pkgs)


(define (all-pkgs)
  (let ([hsh (get-all-pkg-details-from-catalogs)])
    (cond
      [(equal? hsh (hash))
       (error 'all-pkgs "empty packages hash")]
      [(not (hash? hsh))
       (error 'all-pkgs "not a hash: \"~v\"" hsh)]
      [else hsh])))
