# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="A set of eselect modules for Java"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Java"
SRC_URI="https://gitweb.gentoo.org/proj/${PN}.git/snapshot/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86 ~amd64-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

RDEPEND="
	!app-eselect/eselect-maven
	app-admin/eselect"

src_prepare() {
	default
	eautoreconf
}

pkg_postinst() {
	local REMOVED=0

	rm -v "${EROOT}"/usr/lib*/nsbrowser/plugins/javaplugin.so 2>/dev/null && REMOVED=1
	rm -v "${EROOT}"/etc/java-config-2/current-icedtea-web-vm 2>/dev/null && REMOVED=1

	if [[ ${REMOVED} = 1 ]]; then
		elog "The eselect java-nsplugin module has been removed and your configuration"
		elog "has been cleaned up. From now on, you may only install either Oracle or"
		elog "IcedTea's plugin but not both. Note you can use IcedTea's plugin with an"
		elog "Oracle VM. See the README installed with icedtea-web for more details."
	fi
}
