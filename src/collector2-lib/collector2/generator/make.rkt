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

(require racket/string
         ebuild
         threading
         upi/basename
         "../epoch.rkt"
         "../repo.rkt"
         "classes.rkt"
         "license/identify.rkt"
         "license/lookup.rkt"
         "name.rkt")

(provide architectures
         license-lookup?
         make-archive
         make-cir
         make-gh
         ;; from classes.rkt
         package-category)


;; Keep in sync with the official Racket package.
;; https://packages.gentoo.org/packages/dev-scheme/racket
(define architectures
  (make-parameter '("~amd64" "~arm" "~ppc" "~ppc64" "~x86")))


(define (get-commit-hash data)
  (let ([c1 (~> data
                (hash-ref 'versions (hash))
                (hash-ref 'default  (hash))
                (hash-ref 'checksum ""))]
        [c2 (hash-ref data 'checksum "")])
    (cond
      [(equal? c1 "") c2]
      [else c1])))

(define (make-valid-description name description)
  (cond
    [(or (< (string-length description) 11)  ; too short
         (> (string-length description) 79)  ; too long
         (equal? description name)  ; too generic  ; CONSIDER: titlecase?
         ;; includes non-ASCII characters
         (not (null? (regexp-match* #rx"[^\x00-\x7F]" description))))
     (string-append "The " name " Racket package")]
    [else
     ;; replace: `, ", \n, \r (^M)
     (string-trim (regexp-replace* #rx"[`\"\n\r]" description ""))]))

(define (normalize-url-string str)
  (~> str
      (regexp-replace "git://" _ "https://")
      (regexp-replace #rx"\\?[a-z]+=.*" _ "")
      (regexp-replace #rx"#.*" _ "")
      (regexp-replace ".git$" _ "")))

(define license-lookup?
  (make-parameter #false))

(define (pick-license src data)
  (cond
    [(hash-ref data 'license #false)
     => (lambda (lic) (identify-license lic))]
    [(license-lookup?)
     (info-lookup/license src)]
    [else
     "all-rights-reserved"]))


;; In case of zip the archive snapshots are not kept,
;; nor any reference to them (versions/snapshots) is required to exist,
;; so we can only generate live ebuilds with that zip URL.

(define (archive-body src)
  (~>> (let ([archive (basename src)])
         (make-script (format "wget -O \"${T}/~a\" \"~a\"" archive src)
                      (format "unpack \"${T}/~a\"" archive)))
       (sh-function "src_unpack")
       sh-function->string))

(define (make-archive name src data)
  (let ([my-ebuild
         (new ebuild-rkt%
              [custom        (list (lambda () "PROPERTIES=live"))]
              [DESCRIPTION
               (make-valid-description name (hash-ref data 'description ""))]
              [HOMEPAGE
               (format "https://pkgs.racket-lang.org/package/~a" name)]
              [RACKET_DEPEND (hash-ref data 'dependencies '())]
              [SRC_URI       '()]
              [S             "${WORKDIR}/${PN}"]
              [KEYWORDS      (architectures)]
              [body          (list (lambda () (archive-body src)))])])
    (new package%
         [CATEGORY (package-category)]
         [PN       (make-valid-name name)]
         [ebuilds  (hash (live-version) my-ebuild)]
         [metadata (new metadata%)])))


(define (make-cir main-name main-src main-data aux-name aux-src aux-data)
  (let* ([main-snapshot
          (epoch->pv (hash-ref main-data 'last-updated 0))]
         [license (pick-license main-src main-data)]
         [ebuild
          (new ebuild-rkt-cir%
               [MAIN_URI (normalize-url-string main-src)]
               [MAIN_PH  (get-commit-hash main-data)]
               [MAIN_S   (or (query-path main-src) "")]
               [AUX_URI  (normalize-url-string aux-src)]
               [AUX_PH   (get-commit-hash aux-data)]
               [AUX_S    (or (query-path aux-src) "")]
               [AUX_PKG  aux-name]
               [RACKET_DEPEND
                (remove aux-name  ; dep we want to rm might be a list
                        (~>> main-data
                             (hash-ref _ 'dependencies '())
                             (map (lambda (v) (if (list? v) (car v) v)))))]
               [DESCRIPTION
                (make-valid-description main-name
                                        (hash-ref main-data 'description ""))]
               [HOMEPAGE
                (format "https://pkgs.racket-lang.org/package/~a" main-name)]
               [LICENSE license]
               [KEYWORDS (architectures)])])
    (new package%
         [CATEGORY (package-category)]
         [PN       (make-valid-name main-name)]
         ;; FIXME: handle no commit hash? & pick higher snapshot?
         [ebuilds  (hash (simple-version main-snapshot) ebuild)]
         [metadata (new metadata%)])))


(define (make-gh name src data)
  (let* ([snapshot  (epoch->pv (hash-ref data 'last-updated 0))]
         [gh_dom    (url-top src)]
         [gh_repo   (string->repo src)]
         [gh_web    (string-append "https://" gh_dom "/" gh_repo)]
         [gh_commit (get-commit-hash data)]
         [license   (pick-license src data)]
         [my-ebuild%
          (class ebuild-rkt-gh%
            (super-new
             [GH_DOM  gh_dom]
             [GH_REPO gh_repo]
             [DESCRIPTION
              (make-valid-description name (hash-ref data 'description ""))]
             [HOMEPAGE ""]  ; ebuild-gh class will set this
             [LICENSE license]
             [RACKET_DEPEND (hash-ref data 'dependencies '())]
             [S
              (cond
                [(query-path src)
                 => (lambda (s) (string-append "${S}/" s))]
                [else #false])]))]
         [my-ebuilds
          ;; If "gh_dom" is supported by "gh.eclass" generate both live
          ;; and non-live, otherwise generate only live
          (let ([live-version-only
                 (hash (live-version) (new my-ebuild% [KEYWORDS '()]))])
            (hash-set live-version-only  ; live version
                      (simple-version snapshot)  ; + generated from snapshot
                      (new my-ebuild%
                           [GH_COMMIT gh_commit]
                           [KEYWORDS (architectures)])))]
         [remote-id
          (case gh_dom
            [("github.com") (list (remote-id 'github gh_repo))]
            [("gitlab.com") (list (remote-id 'gitlab gh_repo))]
            [("bitbucket.org") (list (remote-id 'bitbucket gh_repo))]
            [else '()])]
         [my-upstream
          (upstream '() #false #false gh_web remote-id)])
    (new package%
         [CATEGORY (package-category)]
         [PN       (make-valid-name name)]
         [ebuilds  my-ebuilds]
         [metadata (new metadata% [upstream my-upstream])])))
