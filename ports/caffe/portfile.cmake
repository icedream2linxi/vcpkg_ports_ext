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
set(GIT_URL "https://github.com/BVLC/caffe.git")
set(GIT_REF "6bfc5ca8f7c2a4b7de09dfe7a01cf9d3470d22b3")

if(NOT EXISTS "${DOWNLOADS}/caffe.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/caffe.git
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
        WORKING_DIRECTORY ${DOWNLOADS}/caffe.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
endif()
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

# vcpkg_apply_patches(
#     SOURCE_PATH ${SOURCE_PATH}
#     PATCHES
#     ${CMAKE_CURRENT_LIST_DIR}/fixed_vcpkg_build.patch
# )


find_program(PYTHON2 NAMES python2 python PATHS C:/python27 E:/Python27 c:/Python27amd64 ENV PYTHON)
if (PYTHON2 MATCHES "NOTFOUND")
    message(FATAL_ERROR "Python 2.7 not found!")
endif()
get_filename_component(PYTHON2_DIR ${PYTHON2} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON2_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DUSE_LEVELDB:BOOL=OFF
            -DUSE_PREBUILT_DEPENDENCIES:BOOL=OFF
            -DCPU_ONLY:BOOL=OFF
            -DUSE_CUDNN:BOOL=ON
            -DUSE_NCCL:BOOL=OFF
            -DBUILD_python_layer:BOOL=ON
            -DBUILD_python:BOOL=ON
            -DBUILD_matlab:BOOL=OFF
            -DCOPY_PREREQUISITES:BOOL=OFF
            -DINSTALL_PREREQUISITES:BOOL=OFF
            -DUSE_OPENMP:BOOL=OFF
            -DBLAS=Open
)

vcpkg_install_cmake()

# move debug targets
file(READ ${CURRENT_PACKAGES_DIR}/debug/share/caffe/CaffeTargets-debug.cmake CAFFE_DEBUG_TARGETS)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" CAFFE_DEBUG_TARGETS "${CAFFE_DEBUG_TARGETS}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/caffe/CaffeTargets-debug.cmake "${CAFFE_DEBUG_TARGETS}")

# remove include and share directories in debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# move tools
file(GLOB _exe_tools ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(COPY ${_exe_tools} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE ${_exe_tools})

# remove debug tools
file(GLOB _exe_tools ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${_exe_tools})

# remove python files
# file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/python)
# file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/python)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/caffe)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/caffe/LICENSE ${CURRENT_PACKAGES_DIR}/share/caffe/copyright)
