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
 (only-in racket/string string-join)
 "private/collector2.rkt"
 )


(define (action:show)
  {define r (repository)}
  (send r show)
  (displayln (string-append "\n" ">>> Packages generated: "
                            (number->string (length (get-field packages r)))))
  )

(define (action:create [root "."])
  (send (repository) save-packages (path->complete-path root))
  )


(module+ main

  (define create-directory (make-parameter (current-directory)))
  (define action (make-parameter 'show))

  (command-line
   #:program "collector2"

   #:multi
   [("-e" "--exclude")
    package
    "Exclude a given package from being generated"
    (let ([valid-name (make-valid-name package)])
      (excluded (append (excluded)
                        (if (equal? package valid-name)
                            (list package) (list package valid-name))
                        )))
    ]

   #:once-each
   [("-d" "--directory")
    directory
    "Set the directory for \"create\" option"
    (create-directory directory)
    ]

   #:once-any
   [("-c" "--create")
    "Create ebuilds in a directory specified by \"directory\" option"
    (action 'create)
    ]
   [("-s" "--show")
    "Dump ebuilds to standard out, do not write to disk"
    (action 'show)
    ]

   #:ps ""
   "Copyright (c) 2021, src_prepare group"
   "Licensed under the GNU GPL v3 License"
   )

  (let ([e (excluded)])
    (when (not (null? e))
      (printf "Excluding: ~a\n" (string-join e))
      ))

  (case (action)
    [(show)    (action:show)]
    [(create)  (action:create (create-directory))]
    )
  )
