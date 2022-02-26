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
 racket/contract
 ebuild
 ebuild/templates/gh
 threading
 upi/basename
 "name.rkt"
 )

(provide
 ebuild-rkt%
 ebuild-rkt-gh%
 ebuild-rkt-cir%
 )


(define/contract (string->pms-pkg str)
  (-> string? string?)
  (string-append "dev-racket/" (make-valid-name str))
  )

(define/contract (racket-pkg->pms-pkg arg)
  (-> (or/c string? list?) string?)
  (cond
    [(string? arg) (string->pms-pkg arg)]
    ;; NOTICE: #:version is probably unnecessary
    [(list? arg)   (string->pms-pkg (car arg))]
    ))


(define (ebuild-rkt-mixin %)
  (class %
    (init-field [RACKET_DEPEND '()])
    (super-new
     [EAPI      8]
     [inherits  '("racket")]
     [RESTRICT  '("mirror")]
     )
    (inherit-field DEPEND RDEPEND)

    (define/private (unroll-RACKET_DEPEND)
      (sort  (map racket-pkg->pms-pkg RACKET_DEPEND)  string<=?)
      )
    (when (not (null? RACKET_DEPEND))
      (set! RDEPEND (unroll-RACKET_DEPEND))
      (set! DEPEND  '("${RDEPEND}"))
      )
    ))

(define ebuild-rkt%
  (ebuild-rkt-mixin ebuild%))

(define ebuild-rkt-gh%
  (ebuild-rkt-mixin ebuild-gh%))

;; Class for resolving circular dependencies in some racket packages
(define ebuild-rkt-cir%
  (class (ebuild-rkt-mixin ebuild%)
    (init-field
     MAIN_URI MAIN_PH MAIN_S
     AUX_URI AUX_PH AUX_S AUX_PKG
     )
    (super-new
     [custom (list (format "MAIN_PH=~a\nAUX_PH=~a" MAIN_PH AUX_PH))]
     [SRC_URI
      (list (src-uri #f (format "~a/archive/${MAIN_PH}.tar.gz" MAIN_URI)
                     "${P}.tar.gz")
            (src-uri #f (format "~a/archive/${AUX_PH}.tar.gz" AUX_URI)
                     (format "${PN}_aux_~a-${PV}.tar.gz" AUX_PKG)))]
     [S
      (format"${WORKDIR}/~a-${MAIN_PH}/~a" (basename MAIN_URI) MAIN_S)]
     [PDEPEND
      (list (racket-pkg->pms-pkg AUX_PKG))]
     [body
      (list
       (~>>
        (make-script
         (format "pushd \"${WORKDIR}/~a-${AUX_PH}/~a\" >/dev/null || die"
                 (basename AUX_URI) AUX_S)
         (format "raco_bare_install user ~a" AUX_PKG)
         "popd >/dev/null || die\n"
         "racket_src_compile"
         )
        (sh-function "src_compile")
        sh-function->string
        )
       (~>>
        (make-script #<<EOF
if has_version "dev-scheme/racket" && racket-where "${RACKET_PN}" ; then
EOF
                     (format "\traco_remove \"${RACKET_PN}\" ~a" AUX_PKG)
                     "fi")
        (sh-function "pkg_prerm")
        sh-function->string
        )
       (~>>
        (make-script "raco_system_install\n"
                     (format "has_version ~a &&" (racket-pkg->pms-pkg AUX_PKG))
                     (format "\traco_system_setup \"${RACKET_PN}\" ~a" AUX_PKG)
                     )
        (sh-function "pkg_postinst")
        sh-function->string
        )
       )]
     )
    ))
