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


#lang racket

(require
 "helpers.rkt"
 "repo.rkt"
 )


(module+ test
  (require rackunit)

  (check-equal? (empty:empty-else "" "")  "")
  (check-equal? (empty:empty-else "" 1)  "")
  (check-equal? (empty:empty-else "_" 1)  1)

  (check-equal? (trim "" '())  "")
  (check-equal? (trim "123sample321" '())  "123sample321")
  (check-equal? (trim "123sample321" '("1" "2" "3"))  "sample")

  (check-equal? (url-path "")  "")
  (check-equal? (url-path "http://example.com")  "/")
  (check-equal? (url-path "http://example.com/")  "/.")
  (check-equal? (url-path "http://example.com/asd/fgh/jkl")  "/asd/fgh/jkl")
  (check-equal? (url-path "http://example.com/asd/fgh/jkl/")  "/asd/fgh/jkl/.")

  (check-equal? (get-branch "")  "")
  (check-equal? (get-branch "fgh/jkl")  "")
  (check-equal? (get-branch "fgh/jkl#trunk")  "trunk")
  (check-equal? (get-branch "fgh/jkl#trunk#trash")  "trunk#trash")

  (check-equal? (remove-branch "")  "")
  (check-equal? (remove-branch "#trunk")  "")
  (check-equal? (remove-branch "fgh/jkl#trunk")  "fgh/jkl")

  (check-equal?
   (string->repo "")
   ""
   )
  (check-equal?
   (string->repo "https://github.com/asd-mirror/asd.git")
   "asd-mirror/asd"
   )
  (check-equal?
   (string->repo "https://github.com/asd-mirror/asd.git#trunk")
   "asd-mirror/asd"
   )
  (check-equal?
   (string->repo "https://gitlab.com/asd-project/asd/asd.git")
   "asd-project/asd/asd"
   )
  (check-equal?
   (string->repo "https://gitlab.com/asd-project/asd/asd.git#trunk")
   "asd-project/asd/asd"
   )

  (check-equal?
   (query-path "")
   #f
   )
  (check-equal?
   (query-path "https://github.com/asd-mirror/asd.git")
   #f
   )
  (check-equal?
   (query-path "https://github.com/asd-mirror/asd.git?path=asd-lib")
   "asd-lib"
   )
  (check-equal?
   (query-path "https://github.com/asd-mirror/asd.git?path=asd-lib#trunk")
   "asd-lib"
   )
  (check-equal?
   (query-path "https://github.com/asd-mirror/asd.git?path=asd/asd-doc/asd-doc#trunk")
   "asd/asd-doc/asd-doc"
   )
  )