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

@require[@for-label[  ; collector2
                    racket/base]]


@title{collector2}

@author[@author+email["Maciej Barć"
                      "xgqt@riseup.net"]]


@section{About}

Parse Racket catalogs and generate ebuild scripts.


@section{Requiring the collector2 module}

@defmodule[collector2]
