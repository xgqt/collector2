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


;; TODO: Docstrings
;;   - https://blog.racket-lang.org/2012/06/submodules.html
;;   - https://docs.racket-lang.org/scribble/srcdoc.html
;; or https://docs.racket-lang.org/reference/procedures.html?q=%20prop%3Aarity-string#%28def._%28%28quote._~23~25kernel%29._prop~3aarity-string%29%29
;; @(require scribble/extract)
;; @include-extracted["X.rkt"]


#lang scribble/manual

@(require
   @(only-in scribble/bnf nonterm)
   @(for-label
     ;; collector2
     racket/base
     )
   )


@title{collector2}

@author[@author+email["Maciej Barć" "xgqt@riseup.net"]]

@table-of-contents[]


@section{About}

Parse Racket catalogs and generate ebuild scripts.


@subsection{Upstream}

This tool is developed by the
@link["https://src_prepare.gitlab.io/" "src_prepare group"].

The upstream repository can be found on
@link["https://gitlab.com/src_prepare/collector2" "GitLab"].


@section{Console usage}

@itemlist[
 @item{
  @Flag{C} @nonterm{create-all-directory}
  or @DFlag{create-all-directory} @nonterm{create-all-directory}
  --- set the directory
  for @DFlag{create-all} to @nonterm{create-all-directory}
 }
 @item{
  @Flag{d} or @DFlag{dump-all}
  --- dump ebuilds to stdout - only show them,
  do not write to the disk
 }
 @item{
  @Flag{c} or @DFlag{create-all}
  --- create ebuilds in a directory (default to the current directory),
  can be overwritten by @DFlag{create-all-directory} flag
 }
 @item{
  @Flag{h} or @DFlag{help}
  --- show help information with usage options
 }
 ]
