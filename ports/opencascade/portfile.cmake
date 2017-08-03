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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/opencascade-7.1.0)
vcpkg_download_distfile(ARCHIVE
    URLS "ftp://fulongkjftp:fulongkeji@svn.fulongtech.cn/SEAL/OpenSource/opencascade-7.1.0.tgz"
    FILENAME "opencascade-7.1.0.tgz"
    SHA512 4b729ccca950e90381ccdd9f407d98af281f02f98212d7fc13be031253f530f75cc1c6e2f2a1a9880ada6626a0c5bd144d991370170745c087313a4bdb2c45b0
)
vcpkg_extract_source_archive(${ARCHIVE})

if("$ENV{TCL_PATH}" STREQUAL "")
    message(FATAL_ERROR "Not found TCL! Please set TCL_PATH environment variable before!")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -D3RDPARTY_TCL_INCLUDE_DIR=$ENV{TCL_PATH}/include
        -D3RDPARTY_TCL_LIBRARY_DIR=$ENV{TCL_PATH}/lib
        -D3RDPARTY_TCL_DLL_DIR=$ENV{TCL_PATH}/bin
        -D3RDPARTY_TK_INCLUDE_DIR=$ENV{TCL_PATH}/include
        -D3RDPARTY_TK_LIBRARY_DIR=$ENV{TCL_PATH}/lib
        -D3RDPARTY_TK_DLL_DIR=$ENV{TCL_PATH}/bin
        -DINSTALL_DIR_BIN=bin
        -DINSTALL_DIR_INCLUDE=include
        -DINSTALL_DIR_LIB=lib
    # OPTIONS_RELEASE
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/data
    ${CURRENT_PACKAGES_DIR}/samples
    ${CURRENT_PACKAGES_DIR}/src
    ${CURRENT_PACKAGES_DIR}/debug/data
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/samples
    ${CURRENT_PACKAGES_DIR}/debug/src)

file(GLOB NEED_REMOVE_FILES
    ${CURRENT_PACKAGES_DIR}/bin/*.exe
    ${CURRENT_PACKAGES_DIR}/*.bat
    ${CURRENT_PACKAGES_DIR}/*.txt
    ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe
    ${CURRENT_PACKAGES_DIR}/debug/*.bat
    ${CURRENT_PACKAGES_DIR}/debug/*.txt)

file(REMOVE ${NEED_REMOVE_FILES})

file(RENAME ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/lib/OpenCASCADE)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/cmake ${CURRENT_PACKAGES_DIR}/debug/lib/OpenCASCADE)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE_LGPL_21.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/opencascade)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/opencascade/LICENSE_LGPL_21.txt ${CURRENT_PACKAGES_DIR}/share/opencascade/copyright)
