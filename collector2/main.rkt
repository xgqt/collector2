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
 racket/cmdline
 "private/collector2.rkt"
 "private/common/counter.rkt"
 "private/common/separator.rkt"
 )


(define (dump-all)
  (let
      ([cntr (counter)])
    (hash-for-each
     (produced-ebuilds)
     (lambda (p script)
       (displayln separator)
       (displayln (string-append "[" (cntr) "]: " p))
       (newline)
       (displayln script)
       (displayln separator)
       )
     )
    )
  )


(module+ main

  (command-line
   #:program "collector2"

   #:once-each
   [("-d" "--dump-all")  "Dump ebuilds to stdout"
                         (dump-all)
                         ]

   #:ps
   "Copyright (c) 2021, src_prepare group"
   "Licensed under the GNU GPL v3 License"
   )
  )
