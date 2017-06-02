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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/qhull-2015.2)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.qhull.org/download/qhull-2015.2.zip"
    FILENAME "qhull-2015.2.zip"
    SHA512 fa0124755696c67530fd4bfca90bd44acbc53f58a8bfeae6f653fb4e9e37181481585ca7ba9aa01990832385c9f508870de744fa3d2b0d3c2829f999730028c1
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(GLOB NEED_REMOVE_FILES
    ${CURRENT_PACKAGES_DIR}/bin/*.exe
    ${CURRENT_PACKAGES_DIR}/include/libqhull/*.htm
    ${CURRENT_PACKAGES_DIR}/include/libqhull/*.txt
    ${CURRENT_PACKAGES_DIR}/include/libqhull_r/*.htm
    ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe
    )
file(REMOVE ${NEED_REMOVE_FILES})

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/doc
    ${CURRENT_PACKAGES_DIR}/man
    ${CURRENT_PACKAGES_DIR}/debug/doc
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/man
    )

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/qhull)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/qhull/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/qhull/copyright)
