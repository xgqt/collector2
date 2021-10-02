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
 ebuild-lib
 ebuild-templates/gh
 "epoch/epoch.rkt"
 "pkgs/pkgs.rkt"
 "repo/repo.rkt"
 )

(provide
 excluded
 packages
 repository
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


(define/contract (string->pms-pkg str)
  (-> string? string?)
  (string-append "dev-racket/" str)
  )

;; NOTICE:
;; #:version is only useful when we can generate
;;   ebuilds from versions hash

(define/contract (racket-pkg->pms-pkg arg)
  (-> (or/c string? list?) string?)
  (cond
    [(string? arg) (string->pms-pkg arg)]
    [(list? arg)   (string->pms-pkg (car arg))]
    )
  )


(define ebuild-rkt%
  (class ebuild-gh%
    (init-field
     [RACKET_DEPEND  '()]
     )

    (define/private (unroll-RACKET_DEPEND)
      (map racket-pkg->pms-pkg RACKET_DEPEND)
      )

    (super-new
     [EAPI      8]
     [RESTRICT  '("mirror")]
     [HOMEPAGE  ""]  ; CONSIDER: maybe fix in ebuild-gh class?
     )

    (inherit-field inherits DEPEND RDEPEND)

    (set! inherits (append '("racket") inherits))

    (when (not (null? RACKET_DEPEND))
      (set! RDEPEND (unroll-RACKET_DEPEND))
      (set! DEPEND  '("${RDEPEND}"))
      )
    )
  )


(define (packages)
  (hash-map
   (pkgs)
   ;; key - name
   ;; val - data
   (lambda (name data)
     {define src      (hash-ref data 'source "")}
     {define snapshot (epoch->pv (hash-ref data 'last-updated 0))}
     {define gh_dom   (url-top src)}
     {define gh_repo  (string->repo src)}
     {define gh_web   (string-append "https://" gh_dom "/" gh_repo)}
     {define my-ebuild%
       (class ebuild-rkt%
         (super-new
          [GH_DOM     gh_dom]
          [GH_REPO    gh_repo]
          [DESCRIPTION
           (make-valid-description name (hash-ref data 'description ""))]
          [RACKET_DEPEND  (hash-ref data 'dependencies '())]
          [S
           (cond
             [(query-path src) => (lambda (s) (string-append "${S}/" s))]
             [else  #f]
             )]
          ))}
     {define my-ebuilds
       ;; If "gh_dom" is supported by "gh.eclass" generate both live
       ;; and non-live, otherwise generate only live
       (let ([live-version-only
              (hash (live-version) (new my-ebuild% [KEYWORDS '()]))])
         (if (regexp-match-exact?
              #rx".*(bitbucket|codeberg|git.sr.ht|github|gitlab).*" gh_dom
              )
             ;; live version + generated from "snapshot"
             (hash-set live-version-only
                       (simple-version snapshot)
                       (new my-ebuild%
                            [GH_COMMIT  (hash-ref data 'checksum "")]
                            [KEYWORDS   '("~amd64")]
                            ))
             ;; live version only
             live-version-only
             )
         )}
     {define my-upstream
       (upstream  ; maintainers changelog doc bugs-to remote-ids
        '() #f #f gh_web
        (case gh_dom
          [("github.com")  (list (remote-id 'github gh_repo))]
          [("gitlab.com")  (list (remote-id 'gitlab gh_repo))]
          [else  '()]
          )
        )
       }
     (new package%
          [CATEGORY  "dev-racket"]
          [PN        (make-valid-name name)]
          [ebuilds   my-ebuilds]
          [metadata  (new metadata% [upstream my-upstream])]
          )
     )
   )
  )

(define (repository)
  (new repository%
       [name "racket-overlay"]
       [packages (packages)]
       )
  )
