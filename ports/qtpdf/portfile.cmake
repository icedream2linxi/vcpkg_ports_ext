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
find_program(GIT git)
set(GIT_URL "https://github.com/qt-labs/qtpdf.git")
set(GIT_REF "45b18c4a18a60907496e2738f6f3c75334ec260f")

set(USE_PROXY 1)

if (${USE_PROXY})
    set(PROXY_HOST "127.0.0.1")
    set(PROXY_PORT "1080")
    set(ENV{http_proxy} "http://${PROXY_HOST}:${PROXY_PORT}")
    set(ENV{https_proxy} "http://${PROXY_HOST}:${PROXY_PORT}")
endif()

if(NOT EXISTS "${DOWNLOADS}/qtpdf.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/qtpdf.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree and patching")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/qtpdf.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
endif()
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

message(STATUS "Updating Submodule")
vcpkg_execute_required_process(
    COMMAND ${GIT} submodule update --init --recursive
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME update-submodule
)

# vcpkg_apply_patches(
#     SOURCE_PATH ${SOURCE_PATH}
#     PATCHES
#     ${CMAKE_CURRENT_LIST_DIR}/fix-build-plugin-vrml.patch
#     ${CMAKE_CURRENT_LIST_DIR}/switch-build-ffmpeg-plugin.patch
# )

# Acquire tools
set(ENV{PATH} "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/bin;${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/tools/qt5;$ENV{PATH}")

message(STATUS "QMake")
vcpkg_execute_required_process(
    COMMAND qmake
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME qmake
)

vcpkg_find_acquire_program(PYTHON2)
vcpkg_find_acquire_program(PERL)

get_filename_component(PYTHON2_DIR ${PYTHON2} DIRECTORY)
get_filename_component(PERL_DIR ${PERL} DIRECTORY)
set(ENV{PATH} "${PYTHON2_DIR};${PERL_DIR};$ENV{PATH}")

message(STATUS "NMake Release")
vcpkg_execute_required_process(
    COMMAND nmake release
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME nmake-release
)

set(ENV{LIB} "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/debug/lib;$ENV{LIB}")
message(STATUS "NMake Debug")
vcpkg_execute_required_process(
    COMMAND nmake debug
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME nmake-debug
)

file(GLOB COPY_FILES LIST_DIRECTORIES  true ${SOURCE_PATH}/Include/*)
file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(GLOB COPY_FILES ${SOURCE_PATH}/src/pdf/*.h)
file(COPY ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/QtPdf)
file(MAKE_DIRECTORY ${SOURCE_PATH}/include/QtPdf/5.9.0/QtPdf/private/)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/QtPdf/qpdfdocument_p.h ${CURRENT_PACKAGES_DIR}/include/QtPdf/5.9.0/QtPdf/private/qpdfdocument_p.h)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/QtPdf/headers.pri)

file(GLOB COPY_FILES LIST_DIRECTORIES  true ${SOURCE_PATH}/lib/cmake/*)
file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)

file(INSTALL ${SOURCE_PATH}/lib/Qt5Pdf.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${SOURCE_PATH}/lib/Qt5Pdf.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/lib/Qt5Pdfd.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(INSTALL ${SOURCE_PATH}/lib/Qt5Pdfd.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.LGPLv3 DESTINATION ${CURRENT_PACKAGES_DIR}/share/qtpdf RENAME copyright)