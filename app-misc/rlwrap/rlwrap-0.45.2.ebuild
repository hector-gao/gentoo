# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="GNU readline wrapper"
HOMEPAGE="https://github.com/hanslub42/rlwrap"
SRC_URI="https://github.com/hanslub42/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~mips ~ppc ~x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos"
IUSE="debug"

RDEPEND="sys-libs/readline:0="
DEPEND="${RDEPEND}"

src_prepare() {
	default
	autoreconf --install
}

src_configure() {
	econf $(use_enable debug)
}
