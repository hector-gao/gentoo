# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xorg-3

DESCRIPTION="X.Org xeyes application"

KEYWORDS="~alpha amd64 arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 sparc ~x86 ~amd64-linux ~x86-linux ~sparc64-solaris"

RDEPEND="
	>=x11-libs/libXi-1.7
	x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXext
	x11-libs/libXmu
	x11-libs/libXrender
	x11-libs/libxcb"
DEPEND="${RDEPEND}
	x11-base/xorg-proto"

XORG_CONFIGURE_OPTIONS=( --with-xrender --with-present )
