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


(module+ main
  (require
   racket/format
   "../common/counter.rkt"
   "../common/separator.rkt"
   "all.rkt"
   )


  (define cntr (counter))

  (hash-for-each
   all-pkgs-hash
   (lambda (name data)
     (displayln (string-append separator             "\n"
                               "number: " (cntr)     "\n"
                               "name:   " (~a name)  "\n"
                               "data:   " (~v data)  "\n"
                               separator             "\n"
                               )))
   )
  )