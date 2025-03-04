# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
PYTHON_REQ_USE="threads(+)"

VIRTUALX_REQUIRED="manual"

inherit distutils-r1 multiprocessing optfeature virtualx

DESCRIPTION="Powerful data structures for data analysis and statistics"
HOMEPAGE="https://pandas.pydata.org/ https://github.com/pandas-dev/pandas/"
SRC_URI="
	https://github.com/pandas-dev/pandas/releases/download/v${PV}/${P}.tar.gz"
S="${WORKDIR}/${P/_/}"

SLOT="0"
LICENSE="BSD"
KEYWORDS="amd64 arm arm64 ppc ppc64 ~riscv ~s390 ~x86"
IUSE="doc full-support minimal test X"
RESTRICT="!test? ( test )"

RECOMMENDED_DEPEND="
	>=dev-python/bottleneck-1.2.1[${PYTHON_USEDEP}]
	>=dev-python/numexpr-2.7.0[${PYTHON_USEDEP}]
"

# TODO: add pandas-gbq to the tree
OPTIONAL_DEPEND="
	dev-python/beautifulsoup4[${PYTHON_USEDEP}]
	dev-python/blosc[${PYTHON_USEDEP}]
	|| (
		dev-python/html5lib[${PYTHON_USEDEP}]
		dev-python/lxml[${PYTHON_USEDEP}]
	)
	dev-python/jinja[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	|| (
		dev-python/openpyxl[${PYTHON_USEDEP}]
		dev-python/xlsxwriter[${PYTHON_USEDEP}]
	)
	>=dev-python/pytables-3.2.1[${PYTHON_USEDEP}]
	dev-python/statsmodels[${PYTHON_USEDEP}]
	>=dev-python/xarray-0.12.3[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-1.3.0[${PYTHON_USEDEP}]
	>=dev-python/xlrd-1.2.0[${PYTHON_USEDEP}]
	>=dev-python/xlwt-1.3.0[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.1[${PYTHON_USEDEP}]
	X? (
		|| (
			dev-python/PyQt5[${PYTHON_USEDEP}]
			x11-misc/xclip
			x11-misc/xsel
		)
	)
"
COMMON_DEPEND="
	>=dev-python/numpy-1.17.3[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.8.1-r3[${PYTHON_USEDEP}]
	>=dev-python/pytz-2017.3[${PYTHON_USEDEP}]
"
DEPEND="${COMMON_DEPEND}
	>=dev-python/cython-0.29.21[${PYTHON_USEDEP}]
	doc? (
		${VIRTUALX_DEPEND}
		app-text/pandoc
		dev-python/beautifulsoup4[${PYTHON_USEDEP}]
		dev-python/html5lib[${PYTHON_USEDEP}]
		dev-python/ipython[${PYTHON_USEDEP}]
		dev-python/lxml[${PYTHON_USEDEP}]
		dev-python/matplotlib[${PYTHON_USEDEP}]
		dev-python/nbsphinx[${PYTHON_USEDEP}]
		>=dev-python/numpydoc-0.9.1[${PYTHON_USEDEP}]
		>=dev-python/openpyxl-1.6.1[${PYTHON_USEDEP}]
		>=dev-python/pytables-3.0.0[${PYTHON_USEDEP}]
		dev-python/pytz[${PYTHON_USEDEP}]
		dev-python/rpy[${PYTHON_USEDEP}]
		dev-python/sphinx[${PYTHON_USEDEP}]
		dev-python/xlrd[${PYTHON_USEDEP}]
		dev-python/xlwt[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		x11-misc/xclip
	)
	test? (
		${VIRTUALX_DEPEND}
		${RECOMMENDED_DEPEND}
		${OPTIONAL_DEPEND}
		dev-python/beautifulsoup4[${PYTHON_USEDEP}]
		dev-python/hypothesis[${PYTHON_USEDEP}]
		dev-python/openpyxl[${PYTHON_USEDEP}]
		dev-python/pymysql[${PYTHON_USEDEP}]
		>=dev-python/pytest-6[${PYTHON_USEDEP}]
		dev-python/pytest-xdist[${PYTHON_USEDEP}]
		dev-python/psycopg:2[${PYTHON_USEDEP}]
		dev-python/xlsxwriter[${PYTHON_USEDEP}]
		x11-misc/xclip
		x11-misc/xsel
	)
"
# dev-python/statsmodels invokes a circular dep
#  hence rm from doc? ( ), again
RDEPEND="${COMMON_DEPEND}
	!minimal? ( ${RECOMMENDED_DEPEND} )
	full-support? ( ${OPTIONAL_DEPEND} )
"

python_prepare_all() {
	# Prevent un-needed download during build
	sed -e "/^              'sphinx.ext.intersphinx',/d" \
		-i doc/source/conf.py || die

	# requires package installed
	sed -e '/extra_compile_args =/s:"-Werror"::' \
		-i setup.py || die

	distutils-r1_python_prepare_all
}

python_compile() {
	distutils-r1_python_compile -j1
}

python_compile_all() {
	# To build docs the need be located in $BUILD_DIR,
	# else PYTHONPATH points to unusable modules.
	if use doc; then
		cd "${BUILD_DIR}"/lib || die
		cp -ar "${S}"/doc . && cd doc || die
		LANG=C PYTHONPATH=. virtx ${EPYTHON} make.py html
	fi
}

python_test() {
	local deselect=(
		# test for rounding errors, fails if we have better precision
		# e.g. on amd64 with FMA or on arm64
		# https://github.com/pandas-dev/pandas/issues/38921
		pandas/tests/window/test_rolling.py::test_rolling_var_numerical_issues

		# weird issue, doesn't seem very important
		'pandas/tests/base/test_misc.py::test_memory_usage[series-with-empty-index]'

		# old psycopg2 API
		pandas/tests/tools/test_to_datetime.py::TestToDatetime::test_to_datetime_tz_psycopg2

		# Internet
		pandas/tests/io/xml/test_xml.py::test_wrong_url

		# TODO: some data path problems?
		pandas/tests/io/test_fsspec.py::test_read_csv
		pandas/tests/io/test_fsspec.py::test_markdown_options
	)

	local -x LC_ALL=C.UTF-8
	pushd "${BUILD_DIR}"/lib > /dev/null || die
	"${EPYTHON}" -c "import pandas; pandas.show_versions()" || die
	PYTHONPATH=. virtx epytest pandas --skip-slow --skip-network \
		${deselect[@]/#/--deselect } -m "not single" \
		-n "$(makeopts_jobs "${MAKEOPTS}" "$(get_nproc)")"
	find . '(' -name .pytest_cache -o -name .hypothesis ')' \
		-exec rm -r {} + || die
	popd > /dev/null || die
}

python_install_all() {
	if use doc; then
		dodoc -r "${BUILD_DIR}"/lib/doc/build/html
		einfo "An initial build of docs is absent of references to statsmodels"
		einfo "due to circular dependency. To have them included, emerge"
		einfo "statsmodels next and re-emerge pandas with USE doc"
	fi

	distutils-r1_python_install_all
}

pkg_postinst() {
	optfeature "accelerating certain types of NaN evaluations, using specialized cython routines to achieve large speedups." dev-python/bottleneck
	optfeature "accelerating certain numerical operations, using multiple cores as well as smart chunking and caching to achieve large speedups" ">=dev-python/numexpr-2.1"
	optfeature "needed for pandas.io.html.read_html" dev-python/beautifulsoup4 dev-python/html5lib dev-python/lxml
	optfeature "for msgpack compression using blosc" dev-python/blosc
	optfeature "Template engine for conditional HTML formatting" dev-python/jinja
	optfeature "Plotting support" dev-python/matplotlib
	optfeature "Needed for Excel I/O" ">=dev-python/openpyxl-3.0.0" dev-python/xlsxwriter dev-python/xlrd dev-python/xlwt
	optfeature "necessary for HDF5-based storage" ">=dev-python/pytables-3.2.1"
	optfeature "R I/O support" dev-python/rpy
	optfeature "Needed for parts of pandas.stats" dev-python/statsmodels
	optfeature "SQL database support" ">=dev-python/sqlalchemy-1.3.0"
	optfeature "miscellaneous statistical functions" dev-python/scipy
	optfeature "necessary to use pandas.io.clipboard.read_clipboard support" dev-python/PyQt5 dev-python/pygtk x11-misc/xclip x11-misc/xsel
}
