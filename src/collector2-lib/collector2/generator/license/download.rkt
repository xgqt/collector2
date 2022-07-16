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
 net/url
 threading
 uuid
 (only-in racket/file make-directory*)
 "../../repo.rkt"
 "../../temp-dir.rkt")

(provide (all-defined-out))


;; Example URL:
;; "https://gitlab.com/src_prepare/racket/collector2.git?path=src%2Fcollector2-test"


(define download-format-alias
  (hash "github.com"
        "https://raw.githubusercontent.com/~a/HEAD/~a/info.rkt"
        "gitlab.com"
        "https://gitlab.com/~a/-/raw/HEAD/~a/info.rkt"))


(define (download-pkg-info-file pkg-url-string)
  (let* ([pkg-dom (url-top pkg-url-string)]
         [pkg-repo (string->repo pkg-url-string)]
         [pkg-path (query-path pkg-url-string)]
         [temp-path (build-path (temp-dir) (uuid-string))]
         [info-file (build-path temp-path "info.rkt")]
         [download-url-format
          (hash-ref download-format-alias pkg-dom #false)])
    (make-directory* temp-path)
    (with-handlers ([exn:fail? (lambda _ #false)])
      (cond
        [download-url-format
         (with-output-to-file info-file
           (lambda _
             (~> download-url-format
                 (format pkg-repo (or pkg-path ""))
                 string->url
                 (get-pure-port #:redirections 1)
                 display-pure-port)))
         info-file]
        [else
         #false]))))
