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
set(GIT_URL "https://github.com/castano/nvidia-texture-tools.git")
set(GIT_REF "fa6ebda53f1be0bb40513057d13b154771344528")

if(NOT EXISTS "${DOWNLOADS}/nvidia-texture-tools.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/nvidia-texture-tools.git
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
        WORKING_DIRECTORY ${DOWNLOADS}/nvidia-texture-tools.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
endif()
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/project/vc12/nvtt.sln
    TARGET nvtt
)


file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/src/nvtt/nvtt.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
file(GLOB RELEASE_DLL_FILES ${SOURCE_PATH}/project/vc12/Release.${TRIPLET_SYSTEM_ARCH}/bin/*.dll)
file(INSTALL ${RELEASE_DLL_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
file(GLOB RELEASE_LIB_FILES ${SOURCE_PATH}/project/vc12/Release.${TRIPLET_SYSTEM_ARCH}/lib/*.lib)
file(INSTALL ${RELEASE_LIB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
file(GLOB DEBUG_DLL_FILES ${SOURCE_PATH}/project/vc12/Debug.${TRIPLET_SYSTEM_ARCH}/bin/*.dll)
file(INSTALL ${DEBUG_DLL_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)
file(GLOB DEBUG_LIB_FILES ${SOURCE_PATH}/project/vc12/Debug.${TRIPLET_SYSTEM_ARCH}/lib/*.lib)
file(INSTALL ${DEBUG_LIB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)


vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nvtt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nvtt/LICENSE ${CURRENT_PACKAGES_DIR}/share/nvtt/copyright)
