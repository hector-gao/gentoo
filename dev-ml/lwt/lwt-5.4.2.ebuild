# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit dune

DESCRIPTION="Cooperative light-weight thread library for OCaml"
SRC_URI="https://github.com/ocsigen/lwt/archive/${PV}.tar.gz -> ${P}.tar.gz"
HOMEPAGE="http://ocsigen.org/lwt"

SLOT="0/${PV}"
LICENSE="LGPL-2.1-with-linking-exception"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="+ocamlopt"

DEPEND="
	dev-ml/result:=
	dev-ml/mmap:=
	dev-ml/ocplib-endian:=
	dev-ml/ppxlib:=
	dev-ml/react:=
	dev-ml/luv:=
	dev-libs/libev"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-ml/cppo
	dev-ml/findlib"
