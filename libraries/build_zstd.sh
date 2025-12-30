#!/usr/bin/env bash

[[ -z "${build_helper_file}" ]] && {
	echo "Missing build helper file. Please define \"build_helper_file\""
	exit 1
}

source ${build_helper_file}
[[ $build_helpers_defined -ne 1 ]] && {
    echo "Failed to include build helpers."
    exit 1
}

requires_rebuild ${library_path}
[[ $? -eq 0 ]] && exit 0

_fpic=""
[[ ${build_os_type} == "linux" ]] && _fpic="-fPIC"
_std_options=""
[[ ${build_os_type} == "linux" ]] && _std_options="-static-libstdc++"

# Check if build/cmake exists (older versions) or use Makefile (newer versions)
if [[ -d "${library_path}/build/cmake" ]]; then
    # Old structure: use CMake
    cmake_build ${library_path}/build/cmake -DZSTD_BUILD_PROGRAMS=OFF -DCMAKE_CXX_FLAGS="${_fpic} ${_std_options}" -DCMAKE_BUILD_TYPE=RelWithDebInfo
else
    # New structure: use Makefile
    echo "Using Makefile build (build/cmake not found)"
    cd "${library_path}/lib" || exit 1

    # Build static library
    make clean || true
    CFLAGS="${_fpic}" CXXFLAGS="${_fpic} ${_std_options}" make -j$(nproc) lib-release

    # Create output directory structure
    mkdir -p "../out/${build_os_type}_${build_os_arch}/lib"
    mkdir -p "../out/${build_os_type}_${build_os_arch}/include"

    # Copy library and headers
    cp -f libzstd.a "../out/${build_os_type}_${build_os_arch}/lib/"
    cp -f zstd.h zdict.h zstd_errors.h "../out/${build_os_type}_${build_os_arch}/include/"

    cd - > /dev/null
fi

check_err_exit ${library_path} "Failed to build zstd!"
set_build_successful ${library_path}
