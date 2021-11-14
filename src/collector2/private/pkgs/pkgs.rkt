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
 threading
 "all.rkt"
 "filter.rkt"
 )

(provide
 (all-defined-out)
 filter-verbose?
 )


(define excluded
  (make-parameter '()))


(define (pkgs)
  {define all-pkgs-hash (all-pkgs)}
  (let (
        [main-distribution  (filter-tag "main-distribution" all-pkgs-hash)]
        [main-tests         (filter-tag "main-tests" all-pkgs-hash)]
        [platformed         (filter pkg-for-arch? (hash-keys all-pkgs-hash))]
        )
    (~> all-pkgs-hash
        (hash-filter-source _ #rx".*git.*|.*.zip")  ; only git and zip sources
        (hash-purge-pkgs _ main-tests)
        (hash-purge-pkgs _ main-distribution)
        (hash-purge-pkgs _ platformed)
        (hash-purge-pkgs-chain _ (excluded))  ; "excluded" is a parameter
        hash-filter-failure
        hash-remove-missing-dependencies
        )
    ))
