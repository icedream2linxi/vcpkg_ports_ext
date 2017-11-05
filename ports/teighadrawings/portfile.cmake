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
    URLS "ftp://fulongtech.f3322.net:2521/Software/Teigha/4.03.01/Drawings_vc14_amd64dll.zip"
    FILENAME "Drawings_vc14_amd64dll.zip"
    SHA512 63b85087b0f8027507e5d3d1b8b1dce4858a166df5cbbf63d9fe3860b7970667f21e4c091f6d398f5f5e9dfe81f0399312e3a3b4a659b4f48c2341b4f69b772c
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_download_distfile(ARCHIVE
    URLS "ftp://fulongtech.f3322.net:2521/Software/Teigha/4.03.01/Drawings_vc14_amd64dlldbg.zip"
    FILENAME "Drawings_vc14_amd64dlldbg.zip"
    SHA512 f03dcee74dc4645227c39ad6628cceae86da2e6d3603ae33bfa8cc0f325901d7abea46ab763aca38c725c07ff0e90855641611d24631eeab9a53f95bfa767010
)
vcpkg_extract_source_archive(${ARCHIVE})

file(GLOB COPY_FILES LIST_DIRECTORIES  true ${SOURCE_PATH}/Drawing/Include/* ${SOURCE_PATH}/Dgn/Include/*)
file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(GLOB COPY_FILES ${SOURCE_PATH}/lib/vc14_amd64dll/*)
file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(GLOB COPY_FILES ${SOURCE_PATH}/exe/vc14_amd64dll/*)
file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

file(GLOB REMOVE_FILES ${CURRENT_PACKAGES_DIR}/bin/*.exe
    ${CURRENT_PACKAGES_DIR}/bin/*.manifest
    ${CURRENT_PACKAGES_DIR}/bin/curl.*
    ${CURRENT_PACKAGES_DIR}/bin/sqlite3.*
    ${CURRENT_PACKAGES_DIR}/lib/curl.*
    ${CURRENT_PACKAGES_DIR}/lib/sqlite3.*
    ${CURRENT_PACKAGES_DIR}/lib/ZeroMQ.*
    ${CURRENT_PACKAGES_DIR}/lib/zmq.*
    ${CURRENT_PACKAGES_DIR}/include/OdToolKit.h)
file(REMOVE ${REMOVE_FILES})

file(GLOB COPY_FILES ${SOURCE_PATH}/lib/vc14_amd64dlldbg/*)
file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(GLOB COPY_FILES ${SOURCE_PATH}/exe/vc14_amd64dlldbg/*)
file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(GLOB REMOVE_FILES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe
    ${CURRENT_PACKAGES_DIR}/debug/bin/*.manifest
    ${CURRENT_PACKAGES_DIR}/debug/bin/curl.*
    ${CURRENT_PACKAGES_DIR}/debug/bin/sqlite3.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/curl.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/sqlite3.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/ZeroMQ.*
    ${CURRENT_PACKAGES_DIR}/debug/lib/zmq.*)
file(REMOVE ${REMOVE_FILES})

# Handle copyright
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/teighadrawings)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/teighadrawings/copyright "Teigha Drawings")
