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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ftgl-2.1.3~rc5)
vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/ftgl/files/FTGL%20Source/2.1.3~rc5/ftgl-2.1.3-rc5.tar.bz2/download"
    FILENAME "ftgl-2.1.3-rc5.tar.bz2"
    SHA512 9841bdbe7e299dd0ae3bcbef08dc3a8787a863389bf242aa023b1c2442f3ffc8a2c6768a35d093d27e3ad7197c8228a9b15e795a36824424f05bef66b68c89a4
)
vcpkg_extract_source_archive(${ARCHIVE})

if(EXISTS ${SOURCE_PATH}/msvc/vc140)
    file(REMOVE_RECURSE ${SOURCE_PATH}/msvc/vc140)
endif()

file(COPY ${CURRENT_PORT_DIR}/vc140 DESTINATION ${SOURCE_PATH}/msvc)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/msvc/vc140/ftgl.sln
    OPTIONS /p:FREETYPE_PATH=${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}
)

set(BUILD_PATH ${SOURCE_PATH}/msvc/Build/${VCPKG_TARGET_ARCHITECTURE})

file(COPY ${BUILD_PATH}/ftgl_dll.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${BUILD_PATH}/ftgl_dll.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${BUILD_PATH}/ftgl_dll.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${BUILD_PATH}/ftgl_static.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(COPY ${BUILD_PATH}/ftgl_dll-d.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${BUILD_PATH}/ftgl_dll-d.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${BUILD_PATH}/ftgl_dll-d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY ${BUILD_PATH}/ftgl_static-d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(GLOB SRC_FILES ${SOURCE_PATH}/src/*)
file(COPY ${SRC_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(GLOB CPP_FILES
    ${CURRENT_PACKAGES_DIR}/include/*.cpp
    ${CURRENT_PACKAGES_DIR}/include/*.am
    ${CURRENT_PACKAGES_DIR}/include/*.in
    ${CURRENT_PACKAGES_DIR}/include/*/*.cpp)
file(REMOVE ${CPP_FILES})

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ftgl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ftgl/COPYING ${CURRENT_PACKAGES_DIR}/share/ftgl/copyright)
