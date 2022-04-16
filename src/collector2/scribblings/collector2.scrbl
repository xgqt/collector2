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


#lang scribble/manual

@(require
   @(only-in scribble/bnf nonterm)
   @(for-label
     ;; collector2
     racket/base
     )
   )


@(define (link2overlay pth)
  {define overlay
    "https://gitlab.com/src_prepare/racket/racket-overlay/-/tree/master/"}
  (link (string-append overlay pth) pth)
  )


@title{Collector2}

@author[@author+email["Maciej Barć" "xgqt@riseup.net"]]

@table-of-contents[]

@index-section[]


@section{About}

Parse Racket catalogs and generate ebuild scripts.


@subsection{Upstream}

This tool is developed by the
@link["https://src_prepare.gitlab.io/" "src_prepare group"].

The upstream repository can be found on
@link["https://gitlab.com/src_prepare/racket/collector2" "GitLab"].


@section{Console usage}

@itemlist[
 @item{
  @Flag{C} @nonterm{url} or @DFlag{catalog} @nonterm{url}
  --- set the current-pkg-catalogs catalog to be examined
 }
 @item{
  @Flag{E} @nonterm{package} or @DFlag{exclude} @nonterm{package}
  --- exclude package from being generated,
  treat reverse dependencies as though the package did not exist
 }
 @item{
  @Flag{e} @nonterm{package} or @DFlag{exclude} @nonterm{package}
  --- exclude package and all packages depending on it from being generated
 }
 @item{
  @Flag{d} @nonterm{directory} or @DFlag{directory} @nonterm{directory}
  --- set the directory for @DFlag{create} to a given @nonterm{directory}
  }

 @item{
  @Flag{c} or @DFlag{create}
  --- create ebuilds in a directory (default to the current directory),
  can be overwritten by @DFlag{create-all-directory} flag
 }
 @item{
  @Flag{s} or @DFlag{show}
  --- dump ebuilds to standard out, do not write to the disk
  }

 @item{
  @DFlag{verbose-auto-catalog}
  --- show if automatically setting the Racket catalogs
  }
 @item{
  @DFlag{verbose-exclude}
  --- show manually excluded packages
  }
 @item{
  @DFlag{verbose-filter}
  --- show filtered packages
  }
 @item{
  @Flag{v} or @DFlag{verbose}
  --- increase verbosity (enable other verbosity switches)
  }

 @item{
  @Flag{h} or @DFlag{help}
  --- show help information with usage options
 }
 ]


@section{Repository generation}

@subsection{Missing files}

Collector2 only generates packages in the "dev-racket" category,
so to get a functional repository out of collector2's output you have
to also add in some files:
@itemlist[
 @item{@link2overlay{eclass}es used by generated ebuilds}
 @item{@link2overlay{profiles/categories}}
 @item{@link2overlay{profiles/repo_name}}
 @item{@link2overlay{metadata/layout.conf}}
 ]
