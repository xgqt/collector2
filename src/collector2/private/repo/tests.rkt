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


#lang racket

(require
 "repo.rkt"
 )


(module+ test

  (require rackunit)


  (check-equal? (url-string->path-string "")  "")
  (check-equal? (url-string->path-string "http://example.com")  "/")
  (check-equal? (url-string->path-string "http://example.com/")  "/.")
  (check-equal?
   (url-string->path-string "http://example.com/asd/fgh/jkl")  "/asd/fgh/jkl")
  (check-equal?
   (url-string->path-string "http://example.com/asd/fgh/jkl/")  "/asd/fgh/jkl/.")

  (check-equal? (url-top "")  "")
  (check-equal? (url-top "example.com")  "")
  (check-equal? (url-top "example.com/asd/fgh/jkl")  "")

  (check-equal? (url-top "http://example")  "example")
  (check-equal? (url-top "http://example.com")  "example.com")
  (check-equal? (url-top "http://example.com/")  "example.com")
  (check-equal? (url-top "http://example.com/asd/fgh/jkl")  "example.com")

  (check-equal? (url-top "http://xyz@example.com")  "xyz@example.com")
  (check-equal? (url-top "http://xyz@example.com/")  "xyz@example.com")
  (check-equal? (url-top "http://xyz@example.com/asd/fgh/jkl")  "xyz@example.com")

  (check-equal? (url-top "http://example.com:123")  "example.com:123")
  (check-equal? (url-top "http://example.com:123/")  "example.com:123")
  (check-equal? (url-top "http://example.com:123/asd/fgh/jkl")  "example.com:123")

  (check-equal? (url-top "http://xyz@example.com:123")  "xyz@example.com:123")
  (check-equal? (url-top "http://xyz@example.com:123/")  "xyz@example.com:123")
  (check-equal? (url-top "http://xyz@example.com:123/asd/fgh/jkl")
                "xyz@example.com:123")

  (check-equal? (string->repo "") "")
  (check-equal?
   (string->repo "https://github.com/asd-mirror/asd.git")
   "asd-mirror/asd")
  (check-equal?
   (string->repo "https://github.com/asd-mirror/asd.git#trunk")
   "asd-mirror/asd")
  (check-equal?
   (string->repo "https://gitlab.com/asd-project/asd/asd.git")
   "asd-project/asd/asd")
  (check-equal?
   (string->repo "https://gitlab.com/asd-project/asd/asd.git#trunk")
   "asd-project/asd/asd")

  (check-false  (query-path ""))
  (check-false  (query-path "https://github.com/asd-mirror/asd.git"))
  (check-equal?
   (query-path "https://github.com/asd-mirror/asd.git?path=asd-lib")
   "asd-lib")
  (check-equal?
   (query-path "https://github.com/asd-mirror/asd.git?path=asd-lib#trunk")
   "asd-lib")
  (check-equal?
   (query-path "https://github.com/asd-mirror/asd.git?path=asd/asd-doc/asd-doc#trunk")
   "asd/asd-doc/asd-doc")

  )
