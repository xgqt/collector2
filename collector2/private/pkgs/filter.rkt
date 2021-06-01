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
 hash-filter-source
 hash-purge-pkgs
 hash-remove-missing-dependencies
 pkg-for-arch?
 )


(define/contract (filter-tag tag hsh)
  (-> string? hash? (listof string?))
  "Produce a list from HSH containing only packages with a matching TAG."
  (filter string?
          (hash-map hsh
                    (lambda (name data)
                      (if (member tag (hash-ref data 'tags '()))
                          name
                          #f
                          )
                      )
                    )
          )
  )

(define arches
  '(
    "aarch64"
    "i386"
    "linux-natipkg"
    "ppc"
    "win32"
    "x86-64"
    "x86_64"
    )
  )

(define/contract (pkg-for-arch? pkg)
  (-> string? boolean?)
  "Check if a PKG is meant for a specific platform."
  (set-member?
   (map (lambda (s) (string-contains? pkg (string-append "-" s)))
        arches)
   #t
   )
  )


(define/contract (hash-filter-source hsh str)
  (-> (and/c hash? immutable?) string?
      (and/c hash? immutable?))
  (hash-filter
   (lambda (h) (string-contains? (hash-ref h 'source "") str))
   hsh
   )
  )


(define/contract (hash-remove-dependencies hsh lst deps)
  (-> (and/c hash? immutable?) list? list?
      (and/c hash? immutable?))
  "Create a hash from HSH where values of keys from LST have DEPS subtracted."
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
    )
  )

(define/contract (hash-purge-pkgs hsh lst)
  (-> (and/c hash? immutable?) (listof string?)
      (and/c hash? immutable?))
  "Create a hash from HSH where packages matching a package name from LST
   are removed from the HSH hash and from the dependencies list of
   remaining packages."
  (let*
      (
       [h  (hash-remove-keys hsh lst)]
       [hk (hash-keys h)]
       )
    (hash-remove-dependencies h hk lst)
    )
  )

(define/contract (dependency-exists v pkgs)
  (-> (or/c list? string?) (listof string?)
      boolean?)
  "Check if V exist in PKGS."
  (cond
    [(list? v)   (set-member? pkgs (car v))]
    [(string? v) (set-member? pkgs v)]
    )
  )

(define/contract (missing-dependencies hsh)
  (-> (and/c hash? immutable?) list?)
  "Given HSH return a list of dependencies that do not exist in it."
  (let
      ([md '()])
    (for
        ([data (hash-values hsh)])
      (for
          ([dep (hash-ref data 'dependencies '())])
        (when (not (dependency-exists dep (hash-keys hsh)))
          (set! md (cons dep md)))
        )
      )
    md
    )
  )

(define/contract (hash-remove-missing-dependencies hsh)
  (-> (and/c hash? immutable?) (and/c hash? immutable?))
  (hash-remove-dependencies hsh (hash-keys hsh) (missing-dependencies hsh))
  )
