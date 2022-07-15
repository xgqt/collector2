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
 "license/lookup.rkt"
 "make.rkt")

(provide
 ;; From pkgs.rkt
 hard-excluded
 soft-excluded
 verbose-filter?
 ;; From lookup.rkt
 verbose-info-lookup?
 ;; From make.rkt
 package-category
 license-lookup?
 ;; Local
 packages
 repository)


;; URLs may contain a placeholder URL with "empty.zip"
;; (ie.: http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip),
;; this is why we have to find a URL without ".zip" if possible

(define (archive? str)
  (list? (regexp-match #rx".*.tar.*|.*.zip$" str)))

(define (data->src data)
  ;; Candidates for source URL.
  (let ([candidate-1
         (~> data
             (hash-ref 'versions (hash))
             (hash-ref 'default (hash))
             (hash-ref 'source ""))]
        [candidate-2
         (hash-ref data 'source "")])
    (cond
      [(or (archive? candidate-1) (equal? candidate-1 ""))
       (cond
         [(or (archive? candidate-2) (equal? candidate-2 ""))
          candidate-1]
         [else
          candidate-2])]
      [else
       candidate-1])))

(define (dep-name v)
  (cond
    [(string? v) v]
    [(list? v) (car v)]
    [else ""]))

(define (get-circular-dependency all-packages package-name package-data)
  (for/first
      ([dependency (hash-ref package-data 'dependencies '())]
       #:when
       (let ([dependency-dependencies
              (~> all-packages
                  (hash-ref (dep-name dependency) (hash))
                  (hash-ref 'dependencies '()))])
         (match dependency-dependencies
           [(list-no-order (list-no-order (== package-name) _ ...) _ ...)
            #true]
           [(list-no-order (== package-name) _ ...)
            #true]
           [_
            #false])))
    (dep-name dependency)))


(define (packages)
  (let ([all-packages (pkgs)])
    (for/list ([(name data) (in-hash all-packages)])
      (let ([src (data->src data)]
            [circular (get-circular-dependency all-packages name data)])
        (cond
          [(and circular (string-contains? src "git"))
           (let ([aux-data (hash-ref all-packages circular (hash))])
             (make-cir name src data circular (data->src aux-data) aux-data))]
          [(string-contains? src "git")
           (make-gh name src data)]
          [else
           (make-archive name src data)])))))

(define (repository)
  (new repository%
       [name "racket-overlay"]
       [packages (packages)]))
