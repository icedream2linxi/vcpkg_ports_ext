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
set(GIT_URL "https://github.com/DanBloomberg/leptonica.git")
set(GIT_REF "d4a61eb03ad2d091a6d8ed1d880bcbcf03ba6b44")

if(NOT EXISTS "${DOWNLOADS}/leptonica.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/leptonica.git
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
        WORKING_DIRECTORY ${DOWNLOADS}/leptonica.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
endif()
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/gif_include_path.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_install_cmake()

FILE(READ ${CURRENT_PACKAGES_DIR}/cmake/LeptonicaTargets.cmake TARGETS_CONTENT)
STRING(REGEX REPLACE "_IMPORT_PREFIX}" "_IMPORT_PREFIX}/../../../" MOD_TARGETS_CONTENT "${TARGETS_CONTENT}" )
FILE(WRITE ${CURRENT_PACKAGES_DIR}/cmake/LeptonicaTargets.cmake "${MOD_TARGETS_CONTENT}")

FILE(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/LeptonicaTargets.cmake TARGETS_CONTENT)
STRING(REGEX REPLACE "_IMPORT_PREFIX}" "_IMPORT_PREFIX}/../../../" MOD_TARGETS_CONTENT "${TARGETS_CONTENT}" )
FILE(WRITE ${CURRENT_PACKAGES_DIR}/debug/cmake/LeptonicaTargets.cmake "${MOD_TARGETS_CONTENT}")

FILE(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/LeptonicaConfig.cmake CONFIG_CONTENT)
STRING(REGEX REPLACE "/debug/" "/" MOD_CONFIG_CONTENT "${CONFIG_CONTENT}" )
FILE(WRITE ${CURRENT_PACKAGES_DIR}/debug/cmake/LeptonicaConfig.cmake "${MOD_CONFIG_CONTENT}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/lib/leptonica)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/cmake ${CURRENT_PACKAGES_DIR}/debug/lib/leptonica)

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/leptonica-license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/leptonica)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/leptonica/leptonica-license.txt ${CURRENT_PACKAGES_DIR}/share/leptonica/copyright)
