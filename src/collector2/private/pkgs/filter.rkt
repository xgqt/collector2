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
 racket/set
 racket/string
 "hash.rkt"
 )

(provide
 filter-tag
 hash-filter-failure
 hash-filter-source
 hash-purge-pkgs
 hash-purge-pkgs-chain
 hash-remove-missing-dependencies
 pkg-for-arch?
 verbose-filter?
 )



(define verbose-filter?
  (make-parameter #f))

(define (filter-print reason pkg-name)
  (when (verbose-filter?)
    (printf "Because of ~a, filtered the package: ~a\n" reason pkg-name)
    ))

(define (filter-return reason pkg-data-hsh)
  (filter-print reason (hash-ref pkg-data-hsh 'name))
  #f
  )


;; Produce a list from HSH containing only packages with a matching TAG
(define/contract (filter-tag tag hsh)
  (-> string? hash? (listof string?))
  (filter string?
          (hash-map hsh (lambda (name data)
                          (if (member tag (hash-ref data 'tags '()))
                              name  #f)))
          ))

(define arches
  '(
    "aarch64"
    "i386"
    "linux" "linux-natipkg"
    "osx"
    "ppc"
    "win32" "windows"
    "x86-64" "x86_64"
    ))

;; Check if a PKG is meant for a specific platform
(define/contract (pkg-for-arch? pkg)
  (-> string? boolean?)
  (set-member?
   (map (lambda (s) (string-contains? pkg (string-append "-" s)))
        arches)
   #t
   ))


(define/contract (hash-filter-failure hsh)
  (-> (and/c hash? immutable?) (and/c hash? immutable?))
  (hash-filter
   (lambda (h)
     (let ([build (hash-ref h 'build (hash))])
       (if (or
            ;; if there is success-log
            (hash-ref build 'success-log #f)
            ;; or both success-log and failure-log are missing
            (and (not (hash-ref build 'success-log #f))
               (not (hash-ref build 'failure-log #f)))
            )
           #t
           (filter-return "build failure" h)
           )))
   hsh
   ))


(define/contract (hash-filter-source hsh rx)
  (-> (and/c hash? immutable?) regexp? (and/c hash? immutable?))
  (hash-filter
   (lambda (h)
     (if (regexp-match-exact? rx (hash-ref h 'source ""))
         #t  (filter-return "wrong source URL" h)
         ))
   hsh
   ))


;; Create a hash from HSH where values of keys from LST have DEPS subtracted
(define/contract (hash-remove-dependencies hsh lst deps)
  (-> (and/c hash? immutable?) list? list?
      (and/c hash? immutable?))
  (cond
    [(null? lst)  hsh]
    [else  (hash-remove-dependencies
            (hash-update
             hsh (car lst)
             (lambda (h) (hash-key-set-subtract h 'dependencies deps))
             )
            (cdr lst)
            deps
            )]
    ))

;; Create a hash from HSH where packages matching a package name from LST
;; are removed from the HSH hash and from the dependencies list of
;; remaining packages
(define/contract (hash-purge-pkgs hsh lst)
  (-> (and/c hash? immutable?) (listof string?)
      (and/c hash? immutable?))
  (for-each (lambda (pkg-name) (filter-print "hash-purge-pkgs" pkg-name)) lst)
  (let*
      (
       [h  (hash-remove-keys hsh lst)]
       [hk (hash-keys h)]
       )
    (hash-remove-dependencies h hk lst)
    ))

;; Create a hash from HSH where packages matching a package name from LST
;; are removed from the HSH hash,
;; also remove packages that depended of removed packages
(define/contract (hash-purge-pkgs-chain hsh lst)
  (-> (and/c hash? immutable?) (listof string?)
      (and/c hash? immutable?))
  (hash-filter
   ;; check if any of package dependencies are included in LST
   (lambda (h)
     (if (null? (set-intersect lst (hash-ref h 'dependencies '())))
         #t (filter-return "hash-purge-pkgs-chain" h)
         ))
   ;; remove packages with keys matching the ones from LST
   (hash-remove-keys hsh lst)
   ))

;; Check if V exist in PKGS
(define/contract (dependency-exists v pkgs)
  (-> (or/c list? string?) (listof string?)
      boolean?)
  (cond
    [(list? v)   (set-member? pkgs (car v))]
    [(string? v) (set-member? pkgs v)]
    ))

;; Given HSH return a list of dependencies that do not exist in it
(define/contract (missing-dependencies hsh)
  (-> (and/c hash? immutable?) list?)
  (let
      ([md '()])
    (for
        ([data (hash-values hsh)])
      (for
          ([dep (hash-ref data 'dependencies '())])
        (when (not (dependency-exists dep (hash-keys hsh)))
          (set! md (cons dep md)))
        ))
    md
    ))

(define/contract (hash-remove-missing-dependencies hsh)
  (-> (and/c hash? immutable?) (and/c hash? immutable?))
  (hash-remove-dependencies hsh (hash-keys hsh) (missing-dependencies hsh))
  )
