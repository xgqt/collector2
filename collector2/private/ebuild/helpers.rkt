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
 racket/contract
 racket/string
 )

(provide (all-defined-out))


(define/contract (string->pms-pkg str)
  (-> string? string?)
  (string-append "dev-racket/" str)
  )

;; TODO:
;; filter dependencies with #:platform ?
;;   ie.: zeromq-r-lib :
;;        ("zeromq-win32-i386" #:platform "win32\\i386")
;;        ("zeromq-win32-x86_64" #:platform "win32\\x86_64")
;;        ("zeromq-x86_64-linux-natipkg" #:platform "x86_64-linux-natipkg"))

;; NOTICE:
;; #:version is only useful when we can generate
;;   ebuilds from versions hash

(define/contract (racket-pkg->pms-pkg arg)
  (-> (or/c string? list?) string?)
  "Wrapper for `string->pms-pkg', also can extract 'version' from ARG."
  (cond
    [(string? arg)  (string->pms-pkg arg)]
    ;; [(equal? 3 (length arg))
    ;;  (case (second arg)
    ;;    [(#:version)  (string-append (string->pms-pkg (car arg)) "-" (third arg))]
    ;;    [else  (string->pms-pkg (car arg))]
    ;;    )
    ;;  ]
    [(list? arg)  (string->pms-pkg (car arg))]
    )
  )

(define/contract (racket-pkgs->pms-pkgs lst)
  (-> list? list?)
  (map racket-pkg->pms-pkg lst)
  )

(define (unroll-deps lst)
  (-> list? string?)
  (string-append
   "\n"
   "DEPEND=\""                    "\n"
   "\t" (string-join lst "\n\t")  "\n"
   "\""                           "\n"
   "RDEPEND=\"${DEPEND}\""        "\n"
   )
  )

(define/contract (racket-pkgs->pms-unrolled lst)
  (-> list? string?)
  "Produce DEPEND (part of the ebuild) containing given dependencies
   from LST translated to PMS format"
  (unroll-deps (racket-pkgs->pms-pkgs lst))
  )
