# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/CGAL-4.10)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-4.10/CGAL-4.10.tar.xz"
    FILENAME "CGAL-4.10.tar.xz"
    SHA512 2029ad647e73692bb38b2ed9606aae61ec1d74df886bb6fd0f4e3388fb08a51de87a1e290df0dcc621a8abc2654915e2d331ec9f6d27ddd9a21f187a165fa09d
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_SHARED_LIBS=ON
        -DWITH_CGAL_Qt5=ON
        -DWITH_Eigen3=ON
        -DWITH_GMP=ON
        -DWITH_MPFR=ON
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(GLOB PDB_FILES "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/*.pdb")
file(COPY ${PDB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share/doc
    ${CURRENT_PACKAGES_DIR}/share/man)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.LGPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/cgal)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cgal/LICENSE.LGPL ${CURRENT_PACKAGES_DIR}/share/cgal/copyright)
