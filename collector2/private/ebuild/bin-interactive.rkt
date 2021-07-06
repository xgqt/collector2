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
 "ebuild.rkt"
 )


(define/contract (yesno description)
  (-> string? boolean?)
  (display (string-append description " [Y/n] ... "))
  (case (string-downcase (read-line))
    [("y" "yes") #t]
    [else #f]
    )
  )

(define (ebuild-interactive)
  (display
   (ebuild
    #:verbose #t

    (begin (display "Package name\nPN= ... ")
           (read-line))

    (begin (display "Package version\nPV= ... ")
           (read-line))

    (begin (if
            (yesno "Racket Package name (different from PN)")
            (begin (display "RACKET_PN= ... ")
                   (read-line))
            #f
            ))

    (begin (display "Git domain\nGH_DOM= ... ")
           (read-line))

    (begin (display "Git repository\nGH_REPO= ... ")
           (read-line))

    (begin (display "Commit hash\nGH_COMMIT ... ")
           (read-line))

    (begin (display "Package license\nLICENSE= ... ")
           (read-line))

    (begin (display "Package description\nDESCRIPTION= ... ")
           (read-line))

    #:req
    (begin (if
            (yesno "Required Racket USE")
            (begin (display "RACKET_REQ_USE= ... ")
                   (read-line))
            #f
            ))

    #:dep
    (begin (if
            (yesno "Other package dependencies")
            (begin (display "DEPEND= ... ")
                   (string-split (read-line)))
            #f
            ))

    #:+dir
    (begin0 (if
             (yesno "Append to build directory")
             (begin (display "S=${S}/ ... ")
                    (read-line))
             #f
             )
      (displayln "")
      )

    )
   )
)


(module+ main
  (ebuild-interactive)
  )
