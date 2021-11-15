# collector2

<p align="center">
    <a href="http://pkgs.racket-lang.org/package/collector2">
        <img src="https://img.shields.io/badge/raco_pkg_install-collector2-aa00ff.svg">
    </a>
    <a href="https://archive.softwareheritage.org/browse/origin/?origin_url=https://gitlab.com/src_prepare/racket/collector2">
        <img src="https://archive.softwareheritage.org/badge/origin/https://gitlab.com/src_prepare/racket/collector2/">
    </a>
    <a href="https://gitlab.com/src_prepare/racket/collector2/pipelines">
        <img src="https://gitlab.com/src_prepare/racket/collector2/badges/master/pipeline.svg">
    </a>
    <a href="https://github.com/xgqt/collector2/actions/workflows/test.yml">
        <img src="https://github.com/xgqt/collector2/actions/workflows/test.yml/badge.svg">
    </a>
    <a href="https://gitlab.com/src_prepare/racket/collector2/">
        <img src="https://gitlab.com/src_prepare/badge/-/raw/master/hosted_on-gitlab-orange.svg">
    </a>
    <a href="https://gentoo.org/">
        <img src="https://gitlab.com/src_prepare/badge/-/raw/master/powered-by-gentoo-linux-tyrian.svg">
    </a>
    <a href="./LICENSE">
        <img src="https://gitlab.com/src_prepare/badge/-/raw/master/license-gplv3-blue.svg">
    </a>
    <a href="https://app.element.io/#/room/#src_prepare:matrix.org">
        <img src="https://gitlab.com/src_prepare/badge/-/raw/master/chat-matrix-green.svg">
    </a>
    <a href="https://gitlab.com/src_prepare/racket/collector2/commits/master.atom">
        <img src="https://gitlab.com/src_prepare/badge/-/raw/master/feed-atom-orange.svg">
    </a>
</p>


# About

Parse [Racket packages catalog](https://pkgs.racket-lang.org/)
and generate [ebuild scripts](https://wiki.gentoo.org/wiki/Ebuild).

## Online Documentation

You can read more documentation
[on GitLab pages](https://src_prepare.gitlab.io/racket/collector2/).


# Installation

## From Packages Catalog

```sh
raco pkg install collector2
```

## From repository

Quick install using Make

```sh
(cd ./src && make install)
```

## Dependencies

- [counter](https://gitlab.com/xgqt/scheme-counter)
- [ebuild](https://gitlab.com/xgqt/racket-ebuild)
- [threading](https://github.com/lexi-lambda/threading)
- [upi](https://gitlab.com/xgqt/upi)


# License

SPDX-License-Identifier: GPL-3.0-only

This file is part of collector2.

collector2 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

collector2 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with collector2.  If not, see <https://www.gnu.org/licenses/>.

Copyright (c) 2021, src_prepare group
Licensed under the GNU GPL v3 License
