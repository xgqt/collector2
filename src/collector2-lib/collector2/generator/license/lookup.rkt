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
 setup/getinfo
 threading
 upi/dirname
 (only-in racket/file delete-directory/files)
 "download.rkt"
 "identify.rkt")

(provide (all-defined-out))


(define verbose-remote-info-file-license
  (make-parameter #true))


;; Remember to guard this call by checking if a git repository URL is passed.

(define (remote-info-file-license pkg-url-string)
  (let* ([info-file (download-pkg-info-file pkg-url-string)]
         [info-dir (and info-file (dirname info-file))]
         [pkg-license
          (cond
            [info-dir
             ;; There are cases we can get a malformed "info.rkt" file.
             (with-handlers ([exn:fail?
                              (lambda (captured-exn)
                                (when (verbose-remote-info-file-license)
                                  (printf "Error retrieving ~v data:~%~v~%"
                                          pkg-url-string
                                          (exn-message captured-exn)))
                                "all-rights-reserved")])
               (~> info-dir
                   get-info/full
                   (#%app 'license (lambda _ 'all-rights-reserved))
                   identify-license))]
            [else
             "all-rights-reserved"])])
    (when (verbose-remote-info-file-license)
      (printf "Got license ~v from URL ~v.~%" pkg-license pkg-url-string))
    (when (and info-dir (directory-exists? info-dir))
      (delete-directory/files info-dir))
    pkg-license))
