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
 "common/epoch.rkt"
 "ebuild/ebuild.rkt"
 "pkgs/pkgs.rkt"
 "repo/repo.rkt"
 )

(provide
 produced-ebuilds
 )


;; asd-9 is a invalid name
;; WORKAROUND: asd-9 -> asd9
(define/contract (make-valid-name name)
  (-> string? string?)
  (let
      (
       [mname name]
       [invalid-numbers (regexp-match* #rx"-[0-9]" name)]
       )
    (for ([in invalid-numbers])
      ;; FIXME: regex ?
      (set! mname (string-replace mname in (string-trim in "-")))
      )
    (string-downcase mname)
    )
  )

(define/contract (make-valid-description name description)
  (-> string? string? string?)
  (if (or
       ;; empty
       (equal? "" description)
       ;; too long
       (> (string-length description) 79)
       ;; includes non-ASCII characters
       (not (null? (regexp-match* #rx"[^\x00-\x7F]" description)))
       )
      (string-append "the " name " Racket package")
      ;; replace: `, ", \n, \r (^M)
      (string-trim (regexp-replace* #rx"[`\"\n\r]" description ""))
      )
  )


;; TODO:
;;   - data->ebuild-variables
;;   - data->ebuild

;; TODO: only pass src_uri and let ebuild do the rest
;;       (also maybe add ebuild-data-validate)

(define/contract (data->ebuild name data)
  (-> string? hash? hash?)
  (let*
      (
       [pn          name]
       [pv          (epoch->pv (hash-ref data 'last-updated 0))]
       [p           (string-append name "-" pv)]
       [src         (hash-ref data 'source "")]
       [gh_dom      (url-top src)]
       [gh_repo     (string->repo src)]
       [gh_commit   (hash-ref data 'checksum "")]
       [description (make-valid-description name (hash-ref data 'description ""))]
       [depend      (hash-ref data 'dependencies #f)]
       [path        (query-path src)]
       )
    (make-hash
     (list
      (cons pv
            (ebuild pn pv
                    gh_dom gh_repo gh_commit
                    "all-rights-reserved"  ; license placeholder
                    description
                    #:dep depend
                    #:+dir path
                    )
            )
      )
     )
    )
  )


(define (produced-ebuilds)
  (make-hash
   ;; NOTICE: map produces a list
   (hash-map (pkgs)
             (lambda (name data)
               (cons (make-valid-name name) (data->ebuild name data)))
             )
   )
  )
