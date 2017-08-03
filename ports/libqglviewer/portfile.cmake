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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libQGLViewer-2.6.4)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.libqglviewer.com/src/libQGLViewer-2.6.4.zip"
    FILENAME "libQGLViewer-2.6.4.zip"
    SHA512 6a3149a44ab08da2bbab6c150371dd341ea04d18743f2c36c0be7021019a9da7f82ac5bafd9817e516d8e6becea510092d70f325b8816cc7b6f31398de47e761
)
vcpkg_extract_source_archive(${ARCHIVE})
# file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/QGLViewer)

vcpkg_configure_qmake(
    SOURCE_PATH ${SOURCE_PATH}/QGLViewer
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_build_qmake()

# Install following vcpkg conventions 
set(BUILD_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})

file(GLOB HEADER_FILES ${SOURCE_PATH}/QGLViewer/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/QGLViewer)

file(INSTALL
    ${SOURCE_PATH}/QGLViewer/QGLViewer2.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL
    ${SOURCE_PATH}/QGLViewer/QGLViewerd2.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(INSTALL
        ${SOURCE_PATH}/QGLViewer/QGLViewer2.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )

    file(INSTALL
        ${SOURCE_PATH}/QGLViewer/QGLViewerd2.dll
        ${SOURCE_PATH}/QGLViewer/QGLViewerd2.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/GPL_exception.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/libQGLViewer)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libQGLViewer/GPL_exception.txt ${CURRENT_PACKAGES_DIR}/share/libQGLViewer/copyright)
