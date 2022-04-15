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
 racket/match
 ebuild
 threading
 "../pkgs/pkgs.rkt"
 "make.rkt"
 )

(provide
 ;; from pkgs.rkt
 hard-excluded
 soft-excluded
 verbose-filter?
 ;; local
 packages
 repository
 )


;; URLs may contain a placeholder URL with "empty.zip"
;; (ie.: http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip),
;; this is why we have to find a URL without ".zip" if possible

(define (archive? str)
  (list? (regexp-match #rx".*.tar.*|.*.zip$" str))
  )

(define (packages)
  {define apkgs (pkgs)}
  (hash-map
   apkgs
   (lambda (name data)
     {define (data->src data)
       (let (  ; candidates for source URL
             [c1  (~> data
                      (hash-ref 'versions (hash))
                      (hash-ref 'default  (hash))
                      (hash-ref 'source   "")
                      )]
             [c2  (hash-ref data 'source "")])
         (if (or (archive? c1) (equal? c1 ""))
             (if (or (archive? c2) (equal? c2 "")) c1  c2)
             c1
             ))}
     {define src (data->src data)}
     {define circular
       (for/first
           ([dependency (hash-ref data 'dependencies '())]
            #:when
            (let* ([dependency-name
                    (cond
                      [(string? dependency)  dependency]
                      [(list?   dependency)  (car dependency)]
                      [else  ""]
                      )]
                   [dependency-dependencies
                    (~> apkgs
                        (hash-ref dependency-name (hash))
                        (hash-ref 'dependencies '())
                        )])
              (match dependency-dependencies
                [(list-no-order (list-no-order (== name) _ ...) _ ...)  #t]
                [(list-no-order (== name) _ ...)  #t]
                [_  #f]
                )))
         (cond
           [(string? dependency)  dependency]
           [(list?   dependency)  (car dependency)]
           [else  ""]
           )
         )}
     (cond
       [(and circular (string-contains? src "git"))
        {define aux-data
          (hash-ref apkgs circular (hash))}
        (make-cir name src data circular (data->src aux-data) aux-data)]
       [(string-contains? src "git")
        (make-gh name src data)]
       [else
        (make-archive name src data)]
       ))
   ))

(define (repository)
  (new repository%
       [name "racket-overlay"]
       [packages (packages)]
       ))
