# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(FTP_URL "fulongtech.f3322.net:2521/Software/Teigha/4.03.01/")
set(FTP_USERNAME "fulongkjftp")
set(FTP_PWD "ftpfulongkj")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)

vcpkg_download_distfile(ARCHIVE
    URLS "ftp://${FTP_USERNAME}:${FTP_PWD}@${FTP_URL}/Kernel_vc14_amd64dll.zip"
    FILENAME "Kernel_vc14_amd64dll.zip"
    SHA512 c5dd628124fb2960a8980da68897949f300a4feeb8babedbc6928b63f81b7a43158e5af6568d2a20c2d3e31686e713730e8ec1559bc72ccbaedfa1b04e9668b3
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_download_distfile(ARCHIVE
    URLS "ftp://${FTP_USERNAME}:${FTP_PWD}@${FTP_URL}/Kernel_vc14_amd64dlldbg.zip"
    FILENAME "Kernel_vc14_amd64dlldbg.zip"
    SHA512 25c167dd778bcb22ba16303bea28d6e9ee52036763c803c1f989ff2dcead54fd617a4d534098993bd7a7c22b2e15d04a2e9ece72a87fe1662f447edef254930c
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_download_distfile(ARCHIVE
    URLS "ftp://${FTP_USERNAME}:${FTP_PWD}@${FTP_URL}/OdActivationInfo"
    FILENAME "OdActivationInfo"
    SHA512 ce007e6b5acad95e7ebe09a296cf5ee52c911a08b3e864487419b6bbb03e3790b3e5a52a0f6e0afb412093705cdafe082a97ba2415cbd4ad71e0ecba1beb4510
)

file(GLOB COPY_FILES LIST_DIRECTORIES  true ${SOURCE_PATH}/Kernel/Include/*)
file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(GLOB COPY_FILES ${SOURCE_PATH}/lib/vc14_amd64dll/*)
file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(GLOB COPY_FILES ${SOURCE_PATH}/exe/vc14_amd64dll/*)
file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

file(GLOB REMOVE_FILES ${CURRENT_PACKAGES_DIR}/bin/*.exe
    ${CURRENT_PACKAGES_DIR}/bin/*.manifest
    ${CURRENT_PACKAGES_DIR}/bin/pcre.*
    ${CURRENT_PACKAGES_DIR}/lib/DwfCore.*
    ${CURRENT_PACKAGES_DIR}/lib/DwfToolkit.*
    ${CURRENT_PACKAGES_DIR}/lib/FreeImage.*
    ${CURRENT_PACKAGES_DIR}/lib/FreeType.*
    ${CURRENT_PACKAGES_DIR}/lib/libcrypto.*
    ${CURRENT_PACKAGES_DIR}/lib/libssl.*
    ${CURRENT_PACKAGES_DIR}/lib/libXML.*
    ${CURRENT_PACKAGES_DIR}/lib/oless.*
    ${CURRENT_PACKAGES_DIR}/lib/pcre.*
    ${CURRENT_PACKAGES_DIR}/lib/qpdf.*
    ${CURRENT_PACKAGES_DIR}/lib/sisl.*
    ${CURRENT_PACKAGES_DIR}/lib/stsflib.*
    ${CURRENT_PACKAGES_DIR}/lib/tinyxml.*)
file(REMOVE ${REMOVE_FILES})

file(GLOB COPY_FILES ${SOURCE_PATH}/lib/vc14_amd64dlldbg/*)
file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(GLOB COPY_FILES ${SOURCE_PATH}/exe/vc14_amd64dlldbg/*)
file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(GLOB REMOVE_FILES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe
    ${CURRENT_PACKAGES_DIR}/debug/bin/*.manifest
    ${CURRENT_PACKAGES_DIR}/debug/bin/pcre.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/DwfCore.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/DwfToolkit.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/FreeImage.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/FreeType.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/libcrypto.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/libssl.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/libXML.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/oless.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/pcre.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/qpdf.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/sisl.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/stsflib.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/tinyxml.*)
file(REMOVE ${REMOVE_FILES})

file(INSTALL ${VCPKG_ROOT_DIR}/downloads/OdActivationInfo DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/teighakernel RENAME copyright)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/teighakernel)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/teighakernel/copyright "Teigha Kernel")
