include(vcpkg_common_functions)
find_program(GIT git)
set(GIT_URL "https://github.com/mariusmuja/flann.git")
set(GIT_REF "06a49513138009d19a1f4e0ace67fbff13270c69")
set(GIT_TAG "1.9.1")

if(NOT EXISTS "${DOWNLOADS}/flann.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/flann.git
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
        WORKING_DIRECTORY ${DOWNLOADS}/flann.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
endif()
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

# Configure and build
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    CURRENT_PACKAGES_DIR ${CURRENT_PACKAGES_DIR}
    OPTIONS
        -DBUILD_DOC=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_MATLAB_BINDINGS=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DBUILD_SHARED_LIBS=ON
        -DCPACK_SOURCE_7Z=OFF
        -DCPACK_SOURCE_ZIP=OFF
        -DCPACK_BINARY_NSIS=OFF
)

vcpkg_install_cmake()

file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/flann.pdb" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(GLOB STATIC_LIBS ${CURRENT_PACKAGES_DIR}/lib/*_s.lib ${CURRENT_PACKAGES_DIR}/debug/lib/*_s.lib)
file(REMOVE ${STATIC_LIBS})

file(REMOVE
    ${CURRENT_PACKAGES_DIR}/lib/flann_cpp.lib
    ${CURRENT_PACKAGES_DIR}/debug/flann_cpp.lib
    ${CURRENT_PACKAGES_DIR}/bin/flann_cpp.dll
    ${CURRENT_PACKAGES_DIR}/debug/bin/flann_cpp.dll)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/flann)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/flann/COPYING ${CURRENT_PACKAGES_DIR}/share/flann/copyright)