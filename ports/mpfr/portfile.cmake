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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mpfr-3.1.5)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.mpfr.org/mpfr-current/mpfr-3.1.5.tar.bz2"
    FILENAME "mpfr-3.1.5.tar.bz2"
    SHA512 ebf94f49e1f850db6304eec8bf3cbf592b9fb06b743e0a99a660edae3c086aa47cdd089ea958fd4631ff02a444ec034b5e45d7e9701704d74c2e2d49021e49a7
)
vcpkg_extract_source_archive(${ARCHIVE})

set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT enabled)

# Acquire tools
vcpkg_acquire_msys(MSYS_ROOT)

# Insert msys into the path between the compiler toolset and windows system32. This prevents masking of "link.exe" but DOES mask "find.exe".
string(REPLACE ";$ENV{SystemRoot}\\system32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\system32;" NEWPATH "$ENV{PATH}")
string(REPLACE ";$ENV{SystemRoot}\\System32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\System32;" NEWPATH "${NEWPATH}")
set(MINGW_PATH ${MSYS_ROOT}/mingw64)
set(ENV{PATH} "${MINGW_PATH}/bin;${NEWPATH}")
set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "pacman -Sy --noconfirm --needed make automake1.15 mingw-w64-x86_64-gcc"
    WORKING_DIRECTORY "${MSYS_ROOT}"
    LOGNAME "pacman-${TARGET_TRIPLET}")

set(AUTOMAKE_DIR ${MSYS_ROOT}/usr/share/automake-1.15)
file(COPY ${AUTOMAKE_DIR}/config.guess ${AUTOMAKE_DIR}/config.sub DESTINATION ${SOURCE_PATH})

# set(CONFIGURE_OPTIONS "--host=x86_64-w64-mingw32")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-static=no --enable-shared=yes")
else()
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-static=yes --enable-shared=no")
endif()

set(VCPKG_INSTALL_DIR ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET})
set(CONFIGURE_OPTIONS_RELASE "--prefix=${CURRENT_PACKAGES_DIR} --enable-thread-safe --with-gmp=${VCPKG_INSTALL_DIR}")

set(ENV{MSYSTEM} MINGW64)

# Configure release
# message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
# file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
# file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
# vcpkg_execute_required_process(
#     COMMAND ${BASH} --noprofile --norc -c 
#         "${SOURCE_PATH}/configure ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_RELASE}"
#     WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
#     LOGNAME "configure-${TARGET_TRIPLET}-rel")
# message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")

# Build release
message(STATUS "Package ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "make -j4 && make install"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    LOGNAME "build-${TARGET_TRIPLET}-rel")
message(STATUS "Package ${TARGET_TRIPLET}-rel done")

file(GLOB DEF_FILES ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/.libs/libmpfr-4.dll.def)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(LIB_MACHINE_ARG /machine:ARM)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(LIB_MACHINE_ARG /machine:x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(LIB_MACHINE_ARG /machine:x64)
else()
    message(FATAL_ERROR "Unsupported target architecture")
endif()

foreach(DEF_FILE ${DEF_FILES})
    get_filename_component(DEF_FILE_DIR "${DEF_FILE}" DIRECTORY)
    get_filename_component(DEF_FILE_NAME "${DEF_FILE}" NAME)
    set(OUT_DEF_FILE "${DEF_FILE_DIR}/${DEF_FILE_NAME}.tmp")
    file(REMOVE "${OUT_DEF_FILE}")
    file(READ "${DEF_FILE}" DEF_CONTENTS)
    file(WRITE "${OUT_DEF_FILE}" "LIBRARY libmpfr-4.dll\n")
    file(APPEND "${OUT_DEF_FILE}" "${DEF_CONTENTS}")
    file(TO_NATIVE_PATH "${OUT_DEF_FILE}" DEF_FILE_NATIVE)
    file(TO_NATIVE_PATH "${DEF_FILE_DIR}/libmpfr-4.lib" OUT_FILE_NATIVE)
    message(STATUS "Generating ${OUT_FILE_NATIVE}")
    vcpkg_execute_required_process(
        COMMAND lib.exe /def:${DEF_FILE_NATIVE} /out:${OUT_FILE_NATIVE} ${LIB_MACHINE_ARG}
        WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}
        LOGNAME libconvert-${TARGET_TRIPLET}
    )
    file(COPY ${OUT_FILE_NATIVE} DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
endforeach()

file(COPY ${MINGW_PATH}/bin/libgcc_s_seh-1.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/)
file(COPY ${MINGW_PATH}/bin/libwinpthread-1.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/)
file(COPY ${MINGW_PATH}/bin/libgcc_s_seh-1.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/)
file(COPY ${MINGW_PATH}/bin/libwinpthread-1.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/libmpfr-4.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/libmpfr-4.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/info)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libmpfr.la)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libmpfr.dll.a)

# Generates warnings about missing pdbs for icudt.dll
# This is expected because ICU database contains no executable code
# vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpfr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mpfr/COPYING ${CURRENT_PACKAGES_DIR}/share/mpfr/copyright)
