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
 "helpers.rkt"
 )

(provide ebuild)


;; TODO: remote other than GitHub
;; TODO: check if \n (newline) is handled properly when outputting to a file


(define/contract
  (ebuild pn        pv
          gh_dom    gh_repo   gh_commit
          license   description
          #:req     [required_use #f]
          #:dep     [dependencies #f]
          #:+dir    [+dir         #f]
          #:verbose [verbose      #f]
          )
  (->*   (
          string?   string?
          string?   string?   string?
          string?   string?
          )
         (
          #:req     (or/c boolean? string?)
          #:dep     (or/c boolean? list?)
          #:+dir    (or/c boolean? string?)
          #:verbose boolean?
          )
         string?
         )
  "Create ebuild script contents."
  (when verbose (displayln (string-append "[EBUILD: " pn "-" pv "]")))
  (let
      (
       [racket_req_use  (if required_use
                            (string-append
                             "\n"
                             "RACKET_REQ_USE=\"" required_use "\""  "\n"
                             ) "")]
       [deps  (if (and (list? dependencies) (not (null? dependencies)))
                  (racket-pkgs->pms-unrolled dependencies) "")]
       [s  (if (and +dir (not (equal? "" +dir)))
               (string-append
                "\n"
                "S=\"${S}/" +dir "\""  "\n"
                ) "")]
       )
    (string-append
     ;; header
     "# Copyright 1999-2021 Gentoo Authors"                               "\n"
     "# Distributed under the terms of the GNU General Public License v2" "\n"
     "\n"
     "EAPI=7"                                        "\n"

     ;; gh variables
     "\n"
     "GH_DOM=\""  gh_dom  "\""                       "\n"
     "GH_REPO=\"" gh_repo "\""                       "\n"

     ;; version
     "\n"
     "if [[ \"${PV}\" != *99999999* ]]; then"        "\n"
     "\t"    "# version: " pv                        "\n"
     "\t"    "GH_COMMIT=\"" gh_commit "\""           "\n"
     "\t"    "KEYWORDS=\"~amd64\""                   "\n"
     "fi"                                            "\n"

     ;; required USE
     racket_req_use

     ;; inherits
     "\n"
     "inherit gh racket"                             "\n"

     ;; description
     "\n"
     "DESCRIPTION=\"" description "\""               "\n"

     ;; homepage
     "HOMEPAGE=\"https://" gh_dom "/" gh_repo "\""   "\n"

     ;; restrictions (remove later)
     "\n"
     "RESTRICT=\"mirror\""                           "\n"

     ;; license
     "LICENSE=\"" license "\""                       "\n"

     ;; slot (maybe "0/PV"?)
     "SLOT=\"0\""                                    "\n"

     ;; dependencies
     deps

     ;; S - temporary build directory
     s
     )
    )
  )
