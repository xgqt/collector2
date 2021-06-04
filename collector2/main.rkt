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
 racket/file
 "private/collector2.rkt"
 "private/common/counter.rkt"
 "private/common/separator.rkt"
 )


(define (dump-all)
  (let
      ([cntr (counter)])
    (hash-for-each
     (produced-ebuilds)
     (lambda (pn hsh)
       (hash-for-each
        hsh
        (lambda (pv script)
          (displayln separator)
          (displayln (string-append "[" (cntr) "]: " pn " - " pv))
          (newline)
          (displayln script)
          (displayln separator)
          )
        )
       )
     )
    )
  )

;; TODO: move to pkgs hash (produced-ebuilds)
(define base-metadata
  (string-append
   "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
   "<!DOCTYPE pkgmetadata SYSTEM \"http://www.gentoo.org/dtd/metadata.dtd\">\n"
   "<pkgmetadata>\n"
   "</pkgmetadata>\n"
   )
  )

(define (create-all [root "."] #:verbose [verbose #f])
  "Create ebuilds in the given location PATH."
  (let*
      (
       [base (build-path root "dev-racket")]
       [cntr (counter)]
       )
    (make-directory* base)
    (hash-for-each
     (produced-ebuilds)
     (lambda (pn hsh)
       ;; dev-racket/PN
       (make-directory* (build-path base pn))
       ;; dev-racket/PN/metadata.xml
       (display-to-file base-metadata
                        (build-path base pn "metadata.xml") #:exists 'replace)
       ;; dev-racket/PN/P.ebuild
       (hash-for-each
        hsh
        (lambda (pv script)
          (let
              ([file-path
                (build-path base pn (string-append pn "-" pv ".ebuild"))
                ])
            (display-to-file script file-path #:exists 'replace)
            (when verbose
              (displayln (string-append
                          "Generated "
                          "[" (cntr) "]: " pn " - " pv
                          " in " (path->string file-path)
                          ))
              )
            )
          )
        )
       )
     )
    (when verbose
      (displayln (string-append "Generated " (cntr #:display #t) " ebuilds"))
      )
    )
  )


(module+ main

  (define create-all-directory-root (make-parameter (current-directory)))
  (define verbose (make-parameter #f))

  (command-line
   #:program "collector2"

   #:once-each
   [("-C" "--create-all-directory")
    create-all-directory
    "Set the directory for `create-all'"
    (create-all-directory-root create-all-directory)
    ]
   [("-v" "--verose")
    "Increate verbosity"
    (verbose #t)
    ]

   #:once-any
   [("-d" "--dump-all")
    "Dump ebuilds to stdout"
    (dump-all)
    ]
   [("-c" "--create-all")
    "Create ebuilds in a DIR"
    (create-all (create-all-directory-root) #:verbose (verbose))
    ]

   #:ps
   "Copyright (c) 2021, src_prepare group"
   "Licensed under the GNU GPL v3 License"
   )
  )
