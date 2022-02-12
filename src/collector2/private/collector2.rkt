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
 racket/match
 racket/string
 ebuild
 ebuild/templates/gh
 threading
 upi/basename
 "epoch/epoch.rkt"
 "pkgs/pkgs.rkt"
 "repo/repo.rkt"
 )

(provide
 excluded
 make-valid-name
 packages
 repository
 verbose-filter?
 )


;; asd-9 is a invalid name
;; WORKAROUND: asd-9 -> asd9
(define/contract (make-valid-name name)
  (-> string? string?)
  (let ([mname name]
        [invalid-numbers (regexp-match* #rx"-[0-9]" name)])
    (for ([in invalid-numbers])
      ;; FIXME: regex ?
      (set! mname (string-replace mname in (string-trim in "-")))
      )
    (string-downcase mname)
    ))

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
      ))

(define/contract (get-commit-hash data)
  (-> hash? string?)
  (let ([c1 (~> data
                (hash-ref 'versions (hash))
                (hash-ref 'default  (hash))
                (hash-ref 'checksum "")
                )]
        [c2 (hash-ref data 'checksum "")])
    (if (equal? c1 "")  c2  c1)
    ))

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
(define ebuild-rkt-cir
  (class (ebuild-rkt-mixin ebuild%)
    (init-field
     MAIN_URI MAIN_PH MAIN_S
     AUX_URI AUX_PH AUX_S AUX_PKG
     )
    (super-new
     [custom
      (list (lambda () (format "MAIN_PH=~a" MAIN_PH))
            (lambda () (format "AUX_PH=~a"  AUX_PH)))]
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
       (lambda ()
         (~>>
          (make-script
           1
           (format "pushd \"${WORKDIR}/~a-${AUX_PH}/~a\" >/dev/null || die"
                   (basename AUX_URI) AUX_S)
           (format "raco_bare_install user ~a" AUX_PKG)
           "popd >/dev/null || die"
           ""
           "racket_src_compile"
           )
          (sh-function "src_compile")
          sh-function->string
          ))
       (lambda ()
         (~>>
          (make-script
           1
           "raco_system_install"
           ""
           (format "if has_version ~a ; then" (racket-pkg->pms-pkg AUX_PKG))
           (make-script 1
                        (format "raco_system_setup ~a" AUX_PKG)
                        "raco_system_setup"
                        )
           "fi"
           )
          (sh-function "pkg_postinst")
          sh-function->string
          ))
       )]
     )
    ))


(define (normalize-url-string str)
  (~> str
      (regexp-replace "git://" _ "https://")
      (regexp-replace #rx"\\?[a-z]+=.*" _ "")
      (regexp-replace #rx"#.*" _ "")
      ))

(define (make-cir main-name main-src main-data aux-name aux-src aux-data)
  {define main-snapshot (epoch->pv (hash-ref main-data 'last-updated 0))}
  ;; {define aux-snapshot  (epoch->pv (hash-ref aux-data  'last-updated 0))}
  {define ebuild
    (new ebuild-rkt-cir
         [MAIN_URI (normalize-url-string main-src)]
         [MAIN_PH (get-commit-hash main-data)]
         [MAIN_S (or (query-path main-src) "")]
         [AUX_URI (normalize-url-string aux-src)]
         [AUX_PH (get-commit-hash aux-data)]
         [AUX_S (or (query-path aux-src) "")]
         [AUX_PKG aux-name]
         [RACKET_DEPEND (remove aux-name  ; dep we want to rm might be a list
                                (~>> main-data
                                     (hash-ref _ 'dependencies '())
                                     (map (lambda (v) (if (list? v) (car v) v)))
                                     ))]
         [DESCRIPTION
          (make-valid-description
           main-name (hash-ref main-data 'description ""))]
         [HOMEPAGE
          (format "https://pkgs.racket-lang.org/package/~a" main-name)]
         )}
  (new package%
       [CATEGORY  "dev-racket"]
       [PN        (make-valid-name main-name)]
       ;; FIXME: handle no commit hash? & pick higher snapshot?
       [ebuilds   (hash (simple-version main-snapshot) ebuild)]
       [metadata  (new metadata%)]
       ))

(define (make-gh name src data)
  {define snapshot (epoch->pv (hash-ref data 'last-updated 0))}
  {define gh_dom   (url-top src)}
  {define gh_repo  (string->repo src)}
  {define gh_web   (string-append "https://" gh_dom "/" gh_repo)}
  {define gh_commit (get-commit-hash data)}
  {define my-ebuild%
    (class ebuild-rkt-gh%
      (super-new
       [GH_DOM         gh_dom]
       [GH_REPO        gh_repo]
       [DESCRIPTION    (make-valid-description name (hash-ref data 'description ""))]
       [HOMEPAGE       ""]  ; ebuild-gh class will set this
       [RACKET_DEPEND  (hash-ref data 'dependencies '())]
       [S              (cond
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
           #rx".*(bitbucket|codeberg|git.sr.ht|github|gitlab).*" gh_dom)
          ;; when gh_dom matches ^
          (hash-set live-version-only  ; live version
                    (simple-version snapshot)  ; + generated from "snapshot"
                    (new my-ebuild%
                         [GH_COMMIT  gh_commit]
                         [KEYWORDS   '("~amd64")]
                         ))
          ;; when it does not match
          live-version-only  ; live version only
          ))}
  {define my-upstream
    (upstream  ; maintainers changelog doc bugs-to remote-ids
     '() #f #f gh_web
     (case gh_dom
       [("github.com")  (list (remote-id 'github gh_repo))]
       [("gitlab.com")  (list (remote-id 'gitlab gh_repo))]
       [else  '()]
       )
     )}
  (new package%
       [CATEGORY  "dev-racket"]
       [PN        (make-valid-name name)]
       [ebuilds   my-ebuilds]
       [metadata  (new metadata% [upstream my-upstream])]
       ))

;; In case of zip the archive snapshots are not kept,
;; nor any reference to them (versions/snapshots) is required to exist,
;; so we can only generate live ebuilds with that zip URL.

(define (archive-body src)
  (~>> (let ([archive (basename src)])
         (make-script 1
                      (format "wget -O \"${T}/~a\" \"~a\"" archive src)
                      (format "unpack \"${T}/~a\"" archive)
                      ))
       (sh-function "src_unpack")
       sh-function->string
       ))

(define (make-archive name src data)
  {define my-ebuild
    (new ebuild-rkt%
         [custom         (list (lambda () "PROPERTIES=live"))]
         [DESCRIPTION    (make-valid-description name (hash-ref data 'description ""))]
         [HOMEPAGE       (format "https://pkgs.racket-lang.org/package/~a" name)]
         [RACKET_DEPEND  (hash-ref data 'dependencies '())]
         [SRC_URI        '()]
         [S              "${WORKDIR}/${PN}"]
         [KEYWORDS       '("~amd64")]  ; unfortunately many pkgs depend on zips
         [body           (list (lambda () (archive-body src)))]
         )}
  (new package%
       [CATEGORY  "dev-racket"]
       [PN        (make-valid-name name)]
       [ebuilds   (hash (live-version) my-ebuild)]
       [metadata  (new metadata%)]
       ))


;; URLs may contain a placeholder URL with "empty.zip"
;; (ie.: http://racket-packages.s3-us-west-2.amazonaws.com/pkgs/empty.zip),
;; this is why we have to find a URL without ".zip" if possible

(define (archive? str)
  (list? (regexp-match #rx".*.tar.*|.*.zip$" str))
  )

(define (packages)
  {define apkgs (pkgs)}
  (hash-map
   apkgs
   (lambda (name data)
     {define (data->src data)
       (let (  ; candidates for source URL
             [c1  (~> data
                      (hash-ref 'versions (hash))
                      (hash-ref 'default  (hash))
                      (hash-ref 'source   "")
                      )]
             [c2  (hash-ref data 'source "")])
         (if (or (archive? c1) (equal? c1 ""))
             (if (or (archive? c2) (equal? c2 "")) c1  c2)
             c1
             ))}
     {define src (data->src data)}
     {define circular
       (for/first
           ([dependency (hash-ref data 'dependencies '())]
            #:when
            (let* ([dependency-name
                    (cond
                      [(string? dependency)  dependency]
                      [(list?   dependency)  (car dependency)]
                      [else  ""]
                      )]
                   [dependency-dependencies
                    (~> apkgs
                        (hash-ref dependency-name (hash))
                        (hash-ref 'dependencies '())
                        )])
              (match dependency-dependencies
                [(list-no-order (list-no-order (== name) _ ...) _ ...)  #t]
                [(list-no-order (== name) _ ...)  #t]
                [_  #f]
                )))
         (cond
           [(string? dependency)  dependency]
           [(list?   dependency)  (car dependency)]
           [else  ""]
           )
         )}
     (cond
       [circular
        {define aux-data
          (hash-ref apkgs circular (hash))}
        (make-cir name src data circular (data->src aux-data) aux-data)]
       [(string-contains? src "git")
        (make-gh name src data)]
       [else
        (make-archive name src data)]
       ))
   ))

(define (repository)
  (new repository%
       [name "racket-overlay"]
       [packages (packages)]
       ))
