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
 (only-in net/url string->url)
 (only-in pkg/lib current-pkg-catalogs)
 )

(provide
 auto-current-pkg-catalogs
 set-current-pkg-catalogs
 )


;; "nop" is the magic keyword to not modify the `current-pkg-catalogs'

(define (set-current-pkg-catalogs url-str)
  (case url-str
    [("auto")   (set-current-pkg-catalogs "https://pkgs.racket-lang.org/")]
    [("false")  (current-pkg-catalogs #f)]
    [("nop")    (void)]
    [else       (current-pkg-catalogs (list (string->url url-str)))]
    ))

(define (auto-current-pkg-catalogs verbose?)
  (when (eq? (current-pkg-catalogs) #f)
    (when verbose?
      (displayln
       "Setting \"current-pkg-catalogs\" to \"https://pkgs.racket-lang.org/\"")
      )
    (set-current-pkg-catalogs "auto")
    ))
