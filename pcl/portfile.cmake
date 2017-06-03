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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pcl-pcl-1.8.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/PointCloudLibrary/pcl/archive/pcl-1.8.0.tar.gz"
    FILENAME "pcl-1.8.0.tar.gz"
    SHA512 185470e980a208bd7213e1087dbc81b9741ae6e8783984e306d34d3e0e4fa69d42aa9c3a2a276d260d11cb89fff9c6cf324401938a66cd3883bdeaa38994e6a1
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/01-Fix_compile_error_C2440_of_pcl_visualization_on_MSVC.patch
            ${CMAKE_CURRENT_LIST_DIR}/02-Fix_Literal_is_not_a_member_of_Eigen_NumTraits.patch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DFLANN_USE_STATIC=ON
        -DQHULL_USE_STATIC=OFF
        -DPCL_BUILD_WITH_BOOST_DYNAMIC_LINKING_WIN32=ON
        "-DCMAKE_CXX_STANDARD_LIBRARIES=kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib delayimp.lib"
        -DCPACK_SOURCE_7Z=OFF
        -DCPACK_SOURCE_ZIP=OFF
        -DWITH_CUDA=ON
        -DWITH_LIBUSB=OFF
        -DWITH_OPENGL=ON
        -DWITH_PCAP=OFF
        -DWITH_QHULL=ON
        -DWITH_QT=ON
        -DWITH_VTK=ON
        -DPCL_SHARED_LIBS=ON
        -DPCL_ENABLE_SSE=ON
        -DBUILD_visualization=ON
        -DBUILD_CUDA=ON
        -DBUILD_GPU=ON
        -DBUILD_surface_on_nurbs=ON
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# The following DLLs have no exports.
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/bin/pcl_2d_release.dll
    ${CURRENT_PACKAGES_DIR}/debug/bin/pcl_2d_debug.dll)

vcpkg_copy_pdbs()

file(RENAME ${CURRENT_PACKAGES_DIR}/include/pcl-1.8/pcl ${CURRENT_PACKAGES_DIR}/include/pcl)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/include/pcl-1.8
    ${CURRENT_PACKAGES_DIR}/debug/include)


file(RENAME ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/lib/PCL)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/cmake ${CURRENT_PACKAGES_DIR}/debug/lib/PCL)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/pcl)
file(GLOB RELEASE_EXE_FILES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
foreach(EXE_FILE ${RELEASE_EXE_FILES})
    get_filename_component(FILE_NAME ${EXE_FILE} NAME)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/${FILE_NAME} ${CURRENT_PACKAGES_DIR}/tools/pcl/${FILE_NAME})
endforeach()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/tools/pcl)
file(GLOB DEBUG_EXE_FILES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
foreach(EXE_FILE ${DEBUG_EXE_FILES})
    get_filename_component(FILE_NAME ${EXE_FILE} NAME)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/${FILE_NAME} ${CURRENT_PACKAGES_DIR}/debug/tools/pcl/${FILE_NAME})
endforeach()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/pcl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pcl/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/pcl/copyright)
