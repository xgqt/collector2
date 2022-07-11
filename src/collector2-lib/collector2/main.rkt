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
 racket/cmdline
 racket/class
 (only-in racket/string string-join)
 "version.rkt"
 "private/generator/generator.rkt"
 "private/generator/name.rkt"
 "private/pkgs/catalogs.rkt")


(define (action:show)
  {define r (repository)}
  (send r show)
  (printf "\n>>> Packages generated:~a\n" (length (get-field packages r))))

(define (action:create [root "."])
  (send (repository) save-packages (path->complete-path root)))

(define (action:only-packages package-names action [root "."])
  (let ([packages (get-field packages (repository))])
    (for ([package-name package-names])
      (for/first ([package packages]
                  #:when (equal? (get-field PN package) package-name))
        (case action
          [(create) (send package save root)]
          [(show)   (send package show)])))))


(module+ main
  (define create-directory
    (make-parameter (current-directory)))

  (define action
    (make-parameter 'show))

  (define only-packages
    (make-parameter '()))

  (define verbose-auto-catalog?
    (make-parameter #f))

  (define verbose-exclude?
    (make-parameter #f))

  (command-line
   #:program "collector2"

   #:multi
   [("-E" "--soft-exclude")
    package
    "Exclude package from being generated, treat reverse dependencies as though the package did not exist"
    (let ([valid-name (make-valid-name package)])
      (soft-excluded (append (soft-excluded)
                             (if (equal? package valid-name)
                                 (list package) (list package valid-name)))))]

   [("-e" "--hard-exclude")
    package
    "Exclude package and all packages depending on it from being generated"
    (let ([valid-name (make-valid-name package)])
      (hard-excluded (append (hard-excluded)
                             (if (equal? package valid-name)
                                 (list package) (list package valid-name)))))]
   [("--only-package")
    package
    "Only create/show the specified package"
    (only-packages (cons package (only-packages)))]
   ;; TODO: --only-package-chain

   #:once-each
   [("-C" "--catalog")
    url
    "Set the current-pkg-catalogs catalog to be examined"
    (set-current-pkg-catalogs url)]
   [("-d" "--directory")
    directory
    "Set the directory for \"create\" option"
    (create-directory directory)]
   [("--package-category")
    category
    "Set the category name to be used for generated packages"
    (package-category category)]
   [("--verbose-auto-catalog")
    "Show if automatically setting the Racket catalogs"
    (verbose-auto-catalog? #t)]
   [("--verbose-exclude")
    "Show manually excluded packages"
    (verbose-exclude? #t)]
   [("--verbose-filter")
    "Show filtered packages"
    (verbose-filter? #t)]
   [("-v" "--verbose")
    "Increase verbosity (enable other verbosity switches)"
    (verbose-filter? #t)
    (verbose-auto-catalog? #t)
    (verbose-exclude? #t)]
   [("-V" "--version")
    "Show the version of this program and immediately exit"
    (printf "Collector2, version ~a on Racket ~a~%" VERSION (version))
    (exit 0)]

   #:once-any
   [("-c" "--create")
    "Create ebuilds in a directory specified by \"directory\" option"
    (action 'create)]
   [("-s" "--show")
    "Dump ebuilds to standard out, do not write to disk"
    (action 'show)]

   #:ps ""
   "Copyright (c) 2021-2022, src_prepare group"
   "Licensed under the GNU GPL v3 License")

  (auto-current-pkg-catalogs (verbose-auto-catalog?))

  (when (verbose-exclude?)
    (printf "Excluding (hash-purge-pkgs-chain): ~a\n"
            (string-join (hard-excluded)))
    (printf "Excluding (hash-purge-pkgs): ~a\n"
            (string-join (soft-excluded))))

  (cond
    [(not (null? (only-packages)))
     (action:only-packages (only-packages) (action) (create-directory))]
    [else
     (case (action)
       [(create) (action:create (create-directory))]
       [(show)   (action:show)])])
  )
