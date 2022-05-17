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
 net/url-string
 threading
 (only-in racket/string string-trim))

(provide
 (contract-out
  [query-path  (-> string? (or/c string? boolean?))]
  [string->repo  (-> string? (or/c string? boolean?))]
  [url-string->path-string  (-> string? string?)]
  [url-top  (-> string? string?)]))


;; Extract the "query path" part of a given STR (treating it as a URL)
(define (query-path url-str)
  (let ([lst (url-query (string->url url-str))])
    (if (null? lst)
        #f
        (cdr (car lst))  ; ie.: '((path . "src"))
        )))


(define banned
  '("."
    ".git"
    "download"
    "main" "master"
    "releases"
    "stable"
    "no-deps" "pre-6" "for-v5.3.6"))

;; Extract the "path" part of a given STR (treating it as a URL)
(define (url-string->path-string str)
  (if (equal? str "")
      ""
      (path->string (url->path (string->url str)))))

;; Trim disallowed elements from `url-path' of given STR
(define (string->repo str)
  (~>> banned
       (foldr (lambda (v acc)
                {define res
                  (string-split acc (string-append "/" v))}
                (if (null? res)
                    ""
                    (car res)))
              (url-string->path-string str))
       (string-trim _ "/")
       (string-trim _ ".git")))


(define (url-top str)
  (let* ([u    (string->url str)]
         [uu   (url-user u)]
         [uh   (url-host u)]
         [_up  (url-port u)]
         [up   (if (integer? _up) (number->string _up) #f)])
    (string-append
     (if uu  (string-append uu "@")  "")  ; user
     (if uh  uh  "")                      ; host
     (if up  (string-append ":" up)  "")  ; port
     )))
