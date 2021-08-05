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
 racket/date
 racket/string
 )

(provide (all-defined-out))


(define/contract (epoch->string seconds)
  (-> integer? string?)
  "Convert SECONDS (since epoch) to a ISO-8601 date string."
  (parameterize ([date-display-format 'iso-8601])
    (date->string (seconds->date seconds))
    )
  )

(define/contract (epoch->pv seconds)
  (-> integer? string?)
  "Strip elements of `epoch->string' to fit PMS (date-like) version standard."
  (string-replace (epoch->string seconds) "-" ".")
  )
