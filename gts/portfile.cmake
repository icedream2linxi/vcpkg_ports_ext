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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gts-0.7.6)
vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/gts/files/gts/0.7.6/gts-0.7.6.tar.gz/download"
    FILENAME "gts-0.7.6.tar.gz"
    SHA512 645123b72dba3d04dad3c5d936d7e55947826be0fb25e84595368919b720deccddceb7c3b30865a5a40f2458254c2af793b7c014e6719cf07e7f8e6ff30890f8
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/01-Fix_build.patch)

set(ENV{INCLUDE} "$ENV{INCLUDE};${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include")
set(ENV{LIB} "$ENV{LIB};${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib")

# Build release
file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/include)

set(ENV{CFLAGS} "-MD -Ox -D_CRT_SECURE_NO_WARNINGS")
message(STATUS "Package ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND nmake -f makefile.msc BIN=${SOURCE_PATH}
    WORKING_DIRECTORY "${SOURCE_PATH}/src"
    LOGNAME "build-${TARGET_TRIPLET}-rel")
message(STATUS "Package ${TARGET_TRIPLET}-rel done")

file(COPY ${SOURCE_PATH}/src/gts-0.7.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/src/gts-0.7.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/src/gts.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/src/gtsconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_execute_required_process(
    COMMAND nmake -f makefile.msc clean BIN=${SOURCE_PATH}
    WORKING_DIRECTORY "${SOURCE_PATH}/src"
    LOGNAME "clean-${TARGET_TRIPLET}-rel")

# Build debug
file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/lib)

set(ENV{CFLAGS} "-Zi -MDd -Od -RTC1 -GS -D_CRT_SECURE_NO_WARNINGS")
set(ENV{LDFLAGS} "-DEBUG")
message(STATUS "Package ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND nmake -f makefile.msc BIN=${SOURCE_PATH}
    WORKING_DIRECTORY "${SOURCE_PATH}/src"
    LOGNAME "build-${TARGET_TRIPLET}-dbg")
message(STATUS "Package ${TARGET_TRIPLET}-dbg done")

file(COPY ${SOURCE_PATH}/src/gts-0.7.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${SOURCE_PATH}/src/gts-0.7.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${SOURCE_PATH}/src/gts-0.7.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gts)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gts/COPYING ${CURRENT_PACKAGES_DIR}/share/gts/copyright)
