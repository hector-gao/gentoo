# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ECM_DESIGNERPLUGIN="true"
ECM_TEST="forceoptional"
PVCUT=$(ver_cut 1-2)
QTMIN=5.15.2
VIRTUALX_REQUIRED="test"
inherit ecm kde.org xdg-utils

DESCRIPTION="Framework providing transparent file and data management"

LICENSE="LGPL-2+"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~riscv ~x86"
IUSE="acl +handbook kerberos +kwallet X"

# tests hang
RESTRICT="test"

RDEPEND="
	dev-libs/libxml2
	dev-libs/libxslt
	>=dev-qt/qtdbus-${QTMIN}:5
	>=dev-qt/qtdeclarative-${QTMIN}:5
	>=dev-qt/qtgui-${QTMIN}:5
	>=dev-qt/qtnetwork-${QTMIN}:5[ssl]
	>=dev-qt/qtwidgets-${QTMIN}:5
	>=dev-qt/qtxml-${QTMIN}:5
	=kde-frameworks/kauth-${PVCUT}*:5
	=kde-frameworks/karchive-${PVCUT}*:5
	=kde-frameworks/kbookmarks-${PVCUT}*:5
	=kde-frameworks/kcodecs-${PVCUT}*:5
	=kde-frameworks/kcompletion-${PVCUT}*:5
	=kde-frameworks/kconfig-${PVCUT}*:5
	=kde-frameworks/kconfigwidgets-${PVCUT}*:5
	=kde-frameworks/kcoreaddons-${PVCUT}*:5
	=kde-frameworks/kcrash-${PVCUT}*:5
	=kde-frameworks/kdbusaddons-${PVCUT}*:5
	=kde-frameworks/kguiaddons-${PVCUT}*:5
	=kde-frameworks/ki18n-${PVCUT}*:5
	=kde-frameworks/kiconthemes-${PVCUT}*:5
	=kde-frameworks/kitemviews-${PVCUT}*:5
	=kde-frameworks/kjobwidgets-${PVCUT}*:5
	=kde-frameworks/knotifications-${PVCUT}*:5
	=kde-frameworks/kservice-${PVCUT}*:5
	=kde-frameworks/ktextwidgets-${PVCUT}*:5
	=kde-frameworks/kwidgetsaddons-${PVCUT}*:5
	=kde-frameworks/kwindowsystem-${PVCUT}*:5
	=kde-frameworks/kxmlgui-${PVCUT}*:5
	=kde-frameworks/solid-${PVCUT}*:5
	acl? (
		sys-apps/attr
		virtual/acl
	)
	handbook? ( =kde-frameworks/kdoctools-${PVCUT}*:5 )
	kerberos? ( virtual/krb5 )
	kwallet? ( =kde-frameworks/kwallet-${PVCUT}*:5 )
	X? ( >=dev-qt/qtx11extras-${QTMIN}:5 )
"
DEPEND="${RDEPEND}
	>=dev-qt/qtconcurrent-${QTMIN}:5
	test? ( sys-libs/zlib )
	X? (
		x11-base/xorg-proto
		x11-libs/libX11
		x11-libs/libXrender
	)
"
PDEPEND=">=kde-frameworks/kded-${PVCUT}:5"

PATCHES=(
	"${FILESDIR}"/${P}-KDirOperator-exp-to-url-only-in-detail-treeview.patch # KDE-bug 440475
	"${FILESDIR}"/${P}-allow-edit-icons-for-root-owned-desktop-files.patch # KDE-bug 429613
	"${FILESDIR}"/${P}-revert-to-pre-libblkid-parsing.patch # bug 821103, KDE-bug 442106
)

src_configure() {
	local mycmakeargs=(
		-DKIO_NO_PUBLIC_QTCONCURRENT=ON
		$(cmake_use_find_package acl ACL)
		$(cmake_use_find_package handbook KF5DocTools)
		$(cmake_use_find_package kerberos GSSAPI)
		$(cmake_use_find_package kwallet KF5Wallet)
		$(cmake_use_find_package X X11)
	)

	ecm_src_configure
}

pkg_postinst() {
	ecm_pkg_postinst
	xdg_desktop_database_update
}

pkg_postrm() {
	ecm_pkg_postrm
	xdg_desktop_database_update
}
