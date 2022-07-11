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
 (only-in racket/file file->lines)
 (only-in racket/port display-lines)
 "../src/collector2-lib/collector2/version.rkt")


(define srcdir
  (build-path (current-directory) "src"))

(define info-files
  (map (lambda (p) (build-path p "info.rkt"))
       (filter directory-exists? (directory-list srcdir #:build? #t))))


(module+ main
  (for ([info-file info-files])
    (define updated
      (map (lambda (l)
             (if (regexp-match "define version" l)
                 (regexp-replace #rx"(?<=version ).*(?=\\))"
                                 l
                                 (format "~s" VERSION))
                 l))
           (file->lines info-file)))
    (with-output-to-file info-file #:exists 'replace
      (lambda () (display-lines updated))))
  )
