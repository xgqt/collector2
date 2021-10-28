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
 net/url
 racket/contract
 racket/string
 )

(provide (all-defined-out))


;; STR - check ; ARG - return
(define-syntax-rule (empty-empty-else str arg)
  (case str
    [("")  ""]
    [else  arg]
    )
  )

;; Trim all occurrences of elements in LST from a STR
(define/contract (trim str lst)
  (-> string? (listof string?) string?)
  (cond
    [(empty? lst)  str]
    [(list? lst)
     (trim
      (string-trim str (car lst) #:left? #t #:right? #t #:repeat? #t)
      (cdr lst)
      )]
    )
  )

;; Extract the "path" part of a given STR (treating it as a URL)
(define/contract (url-path str)
  (-> string? string?)
  (empty-empty-else
   str
   (path->string (url->path (string->url str)))
   )
  )

(define/contract (url-top str)
  (-> string? string?)
  (let*
      (
       [u    (string->url str)]
       [uu   (url-user u)]
       [uh   (url-host u)]
       [_up  (url-port u)]
       [up   (if (integer? _up) (number->string _up) #f)]
       )
    (string-append
     (if uu  (string-append uu "@")  "")  ; user
     (if uh  uh  "")                      ; host
     (if up  (string-append ":" up)  "")  ; port
     )
    )
  )

;; Return a branch from string STR (treat as URL)
(define/contract (get-branch str)
  (-> string? string?)
  (string-trim (regexp-replace #rx"^[^#]*" str "") "#")
  )

;; Remove STR part after "#" (which indicates the git branch)
(define/contract (remove-branch str)
  (-> string? string?)
  (regexp-replace #rx"#.*" str "")
  )
