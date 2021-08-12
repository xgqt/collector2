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
 racket/class
 "private/collector2.rkt"
 )


(define (dump-all)
  {define r (repository)}
  (send r show)
  (displayln (string-append "\n" ">>> Packages generated: "
                            (number->string (length (get-field packages r)))))
  )

(define (create-all [root "."])
  (send (repository) save-packages (path->complete-path root))
  )


(module+ main

  (define create-all-directory-root (make-parameter (current-directory)))
  (define action (make-parameter 'dump-all))

  (command-line
   #:program "collector2"

   #:once-each
   [("-C" "--create-all-directory")
    create-all-directory
    "Set the directory for `create-all'"
    (create-all-directory-root create-all-directory)
    ]

   #:once-any
   [("-d" "--dump-all")
    "Dump ebuilds to stdout"
    (action 'dump-all)
    ]
   [("-c" "--create-all")
    "Create ebuilds in a DIR"
    (action 'create-all)
    ]

   #:ps ""
   "Copyright (c) 2021, src_prepare group"
   "Licensed under the GNU GPL v3 License"
   )

  (case (action)
    [(dump-all)    (dump-all)]
    [(create-all)  (create-all (create-all-directory-root))]
    )
  )
