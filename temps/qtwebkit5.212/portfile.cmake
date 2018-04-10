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
set(GIT_URL "https://github.com/qt/qtwebkit.git")
# set(GIT_REF "0b48569e2bf9afc1b6ca5e359c3a948dd8c77619")
set(GIT_REF "35655d5f4bad248ead1700b59c381cc568b4e98b")

set(USE_PROXY TRUE)

if (${USE_PROXY})
    set(PROXY_HOST "127.0.0.1")
    set(PROXY_PORT "1080")
    set(ENV{http_proxy} "http://${PROXY_HOST}:${PROXY_PORT}")
    set(ENV{https_proxy} "http://${PROXY_HOST}:${PROXY_PORT}")
endif()

if(NOT EXISTS "${DOWNLOADS}/qtwebkit.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/qtwebkit.git
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
        WORKING_DIRECTORY ${DOWNLOADS}/qtwebkit.git
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

vcpkg_find_acquire_program(PYTHON2)
vcpkg_find_acquire_program(PERL)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(RUBY)
vcpkg_find_acquire_program(GPERF)
vcpkg_find_acquire_program(GREP)
vcpkg_find_acquire_program(ICONV)

get_filename_component(PYTHON2_DIR ${PYTHON2} DIRECTORY)
get_filename_component(PERL_DIR ${PERL} DIRECTORY)
get_filename_component(PERL_C_DIR ${PERL_DIR} DIRECTORY)
get_filename_component(PERL_C_DIR ${PERL_C_DIR} DIRECTORY)
set(PERL_C_DIR ${PERL_C_DIR}/c/bin)
get_filename_component(BISON_DIR ${BISON} DIRECTORY)
get_filename_component(FLEX_DIR ${FLEX} DIRECTORY)
get_filename_component(RUBY_DIR ${RUBY} DIRECTORY)
get_filename_component(GPERF_DIR ${GPERF} DIRECTORY)
get_filename_component(GREP_DIR ${GREP} DIRECTORY)
get_filename_component(ICONV_DIR ${ICONV} DIRECTORY)
get_filename_component(CMAKE_DIR ${CMAKE_COMMAND} DIRECTORY)

if (NOT EXISTS ${BISON_DIR}/bison.exe)
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy ${BISON} ${BISON_DIR}/bison.exe
    )
endif()

if (NOT EXISTS ${FLEX_DIR}/flex.exe)
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy ${FLEX} ${FLEX_DIR}/flex.exe
    )
endif()

set(ENV{PATH} "$ENV{PATH};${CMAKE_DIR};${PYTHON2_DIR};${PERL_DIR};${BISON_DIR};${FLEX_DIR};${RUBY_DIR};${GPERF_DIR};${GREP_DIR};${ICONV_DIR}")

set(VcpkgConfigCmake "${SOURCE_PATH}/../vcpkg.config.cmake")
message(STATUS "VcpkgConfigCmake = ${VcpkgConfigCmake}")
set(VCPKG_INSTALLED_DIR ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET})
file(WRITE ${VcpkgConfigCmake} "if(CMAKE_BUILD_TYPE MATCHES \"^Debug$\" OR NOT DEFINED CMAKE_BUILD_TYPE)\n")
file(APPEND ${VcpkgConfigCmake} "link_directories(${VCPKG_INSTALLED_DIR}/debug/lib ${VCPKG_INSTALLED_DIR}/lib)\n")
file(APPEND ${VcpkgConfigCmake} "else()\n")
file(APPEND ${VcpkgConfigCmake} "link_directories(${VCPKG_INSTALLED_DIR}/lib)\n")
file(APPEND ${VcpkgConfigCmake} "endif()\n")

vcpkg_configure_cmake(
SOURCE_PATH ${SOURCE_PATH}
PREFER_NINJA
OPTIONS -DPORT=Qt
        -DENABLE_API_TESTS=OFF
        -DENABLE_TOOLS=OFF
        "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VcpkgConfigCmake}"
)

vcpkg_install_cmake()

# file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include/QtPdf/${QT_VERSION}/QtPdf/private/)

# file(GLOB COPY_FILES LIST_DIRECTORIES  true ${SOURCE_PATH}/Include/*)
# file(COPY ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# file(GLOB COPY_FILES ${SOURCE_PATH}/src/pdf/*.h)

# foreach(COPY_FILE in ${COPY_FILES})
#     get_filename_component(FILE_NAME ${COPY_FILE} NAME)
#     set(REMOVE_FILES ${CURRENT_PACKAGES_DIR}/include/QtPdf/${FILE_NAME} ${REMOVE_FILES})
# endforeach()
# file(REMOVE ${REMOVE_FILES})

# file(COPY ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/QtPdf)
# file(RENAME ${CURRENT_PACKAGES_DIR}/include/QtPdf/qpdfdocument_p.h ${CURRENT_PACKAGES_DIR}/include/QtPdf/${QT_VERSION}/QtPdf/private/qpdfdocument_p.h)

# file(REMOVE ${CURRENT_PACKAGES_DIR}/include/QtPdf/headers.pri)

# file(GLOB COPY_FILES LIST_DIRECTORIES  true ${SOURCE_PATH}/lib/cmake/*)
# file(INSTALL ${COPY_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake)

# file(INSTALL ${SOURCE_PATH}/lib/Qt5Pdf.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
# file(INSTALL ${SOURCE_PATH}/lib/Qt5Pdf.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

# file(INSTALL ${SOURCE_PATH}/lib/Qt5Pdfd.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
# file(INSTALL ${SOURCE_PATH}/lib/Qt5Pdfd.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_execute_required_process(
    COMMAND ${PYTHON3} ${CMAKE_CURRENT_LIST_DIR}/../qt5/fixcmake.py
    WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/cmake
    LOGNAME fix-cmake
)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.LGPLv3 DESTINATION ${CURRENT_PACKAGES_DIR}/share/qtpdf RENAME copyright)