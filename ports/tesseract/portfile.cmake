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
set(GIT_URL "https://github.com/tesseract-ocr/tesseract.git")
set(GIT_REF "215866151e774972c9502282111b998d7a053562")

if(NOT EXISTS "${DOWNLOADS}/tesseract.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/tesseract.git
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
        WORKING_DIRECTORY ${DOWNLOADS}/tesseract.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
endif()
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/fixed_vcpkg_build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DVCPKG_BUILD=ON
)

vcpkg_install_cmake()

FILE(READ ${CURRENT_PACKAGES_DIR}/cmake/TesseractTargets.cmake TARGETS_CONTENT)
STRING(REGEX REPLACE "_IMPORT_PREFIX}" "_IMPORT_PREFIX}/../../../" MOD_TARGETS_CONTENT "${TARGETS_CONTENT}" )
FILE(WRITE ${CURRENT_PACKAGES_DIR}/cmake/TesseractTargets.cmake "${MOD_TARGETS_CONTENT}")

FILE(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/TesseractTargets.cmake TARGETS_CONTENT)
STRING(REGEX REPLACE "_IMPORT_PREFIX}" "_IMPORT_PREFIX}/../../../" MOD_TARGETS_CONTENT "${TARGETS_CONTENT}" )
FILE(WRITE ${CURRENT_PACKAGES_DIR}/debug/cmake/TesseractTargets.cmake "${MOD_TARGETS_CONTENT}")

FILE(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/TesseractConfig.cmake CONFIG_CONTENT)
STRING(REGEX REPLACE "/debug/" "/" MOD_CONFIG_CONTENT "${CONFIG_CONTENT}" )
FILE(WRITE ${CURRENT_PACKAGES_DIR}/debug/cmake/TesseractConfig.cmake "${MOD_CONFIG_CONTENT}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/lib/tesseract)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/cmake ${CURRENT_PACKAGES_DIR}/debug/lib/tesseract)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/tesseract)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/tesseract.exe)
file(GLOB RELEASE_EXE_FILES ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/*.exe)
foreach(EXE_FILE ${RELEASE_EXE_FILES})
    file(COPY ${EXE_FILE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tesseract/)
endforeach()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/tools/tesseract)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/tesseract.exe)
file(GLOB DEBUG_EXE_FILES ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/*.exe)
foreach(EXE_FILE ${DEBUG_EXE_FILES})
    file(COPY ${EXE_FILE} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/tesseract/)
endforeach()

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tesseract)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tesseract/LICENSE ${CURRENT_PACKAGES_DIR}/share/tesseract/copyright)
