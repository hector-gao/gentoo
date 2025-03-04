# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit toolchain-funcs

MY_P=${PN}.app-${PV}
DESCRIPTION="PPP dial control and network load monitor with NeXTStep look"
HOMEPAGE="http://www.dockapps.net/wmpppapp"
SRC_URI="http://www.dockapps.net/download/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND=">=x11-libs/libdockapp-0.7:=
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXpm"
DEPEND="${RDEPEND}"

# Specific to this tarball
S=${WORKDIR}/dockapps-7ec9002

DOCS=( BUGS CHANGES HINTS README TODO )
src_compile() {
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}"
}

src_install() {
	emake DESTDIR="${D}" PREFIX=/usr install
	einstalldocs
}
