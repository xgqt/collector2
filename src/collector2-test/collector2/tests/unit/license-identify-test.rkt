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


(module+ test
  (require
   rackunit
   collector2/generator/license/identify)


  ;; Licene naming conventions

  (test-equal? "BSD"       (SPDX->Gentoo 'BSD-3-Clause)      "BSD")
  (test-equal? "BSD-1"     (SPDX->Gentoo 'BSD-1-Clause)      "BSD-1")
  (test-equal? "BSD-2"     (SPDX->Gentoo 'BSD-2-Clause)      "BSD-2")

  (test-equal? "AGPL-2"    (SPDX->Gentoo 'AGPL-2.0-only)     "AGPL-2")
  (test-equal? "AGPL-2+"   (SPDX->Gentoo 'AGPL-2.0-or-later) "AGPL-2+")
  (test-equal? "AGPL-3"    (SPDX->Gentoo 'AGPL-3.0-only)     "AGPL-3")
  (test-equal? "AGPL-3+"   (SPDX->Gentoo 'AGPL-3.0-or-later) "AGPL-3+")

  (test-equal? "GPL-2"     (SPDX->Gentoo 'GPL-2.0-only)      "GPL-2")
  (test-equal? "GPL-2+"    (SPDX->Gentoo 'GPL-2.0-or-later)  "GPL-2+")
  (test-equal? "GPL-3"     (SPDX->Gentoo 'GPL-3.0-only)      "GPL-3")
  (test-equal? "GPL-3+"    (SPDX->Gentoo 'GPL-3.0-or-later)  "GPL-3+")

  (test-equal? "LGPL-2"    (SPDX->Gentoo 'LGPL-2.0-only)     "LGPL-2")
  (test-equal? "LGPL-2+"   (SPDX->Gentoo 'LGPL-2.0-or-later) "LGPL-2+")
  (test-equal? "LGPL-2.1"  (SPDX->Gentoo 'LGPL-2.1-only)     "LGPL-2.1")
  (test-equal? "LGPL-2.1+" (SPDX->Gentoo 'LGPL-2.1-or-later) "LGPL-2.1+")
  (test-equal? "LGPL-3"    (SPDX->Gentoo 'LGPL-3.0-only)     "LGPL-3")
  (test-equal? "LGPL-3+"   (SPDX->Gentoo 'LGPL-3.0-or-later) "LGPL-3+")


  ;; License expressions

  (test-equal? "GPL-2+"     (identify-license 'GPL-2.0-or-later) "GPL-2+")
  (test-equal? "Apache-2.0" (identify-license 'Apache-2.0) "Apache-2.0")
  (test-equal? "MIT"        (identify-license 'MIT) "MIT")

  (test-equal? "Apache-2.0 and MIT"
               (identify-license '(Apache-2.0 AND MIT))
               "Apache-2.0 MIT")
  (test-equal? "Apache-2.0 or MIT"
               (identify-license '(Apache-2.0 OR MIT))
               "|| ( Apache-2.0 MIT )")

  (test-equal? "GPL-2+ and Apache-2.0 and MIT"
               (identify-license '(GPL-2.0-or-later AND (Apache-2.0 AND MIT)))
               "GPL-2+ Apache-2.0 MIT")
  (test-equal? "GPL-2+ or Apache-2.0 or MIT"
               (identify-license '(GPL-2.0-or-later OR (Apache-2.0 OR MIT)))
               "|| ( GPL-2+ || ( Apache-2.0 MIT ) )")

  (test-equal? "GPL-2+ and Apache-2.0 or MIT"
               (identify-license '(GPL-2.0-or-later AND (Apache-2.0 OR MIT)))
               "GPL-2+ || ( Apache-2.0 MIT )")
  (test-equal? "GPL-2+ or Apache-2.0 and MIT"
               (identify-license '(GPL-2.0-or-later OR (Apache-2.0 AND MIT)))
               "|| ( GPL-2+ Apache-2.0 MIT )")
  )
