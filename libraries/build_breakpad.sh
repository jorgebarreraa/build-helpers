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


if [[ ! ${build_os_type} == "linux" ]]; then
    echo "Linux support only!"
    exit 1
fi

requires_rebuild "${library_path}"
[[ $? -eq 0 ]] && exit 0

cd ${library_path} || { echo "failed to enter library path"; exit 1; }

# Clone linux-syscall-support if not exists (with timeout to prevent hanging)
if [[ ! -d "src/third_party/lss" ]]; then
    echo "Cloning linux-syscall-support..."
    timeout 120 git clone --depth 1 https://chromium.googlesource.com/linux-syscall-support src/third_party/lss || {
        echo "WARNING: Failed to clone linux-syscall-support (timeout or network error)"
        echo "Attempting to continue without it..."
    }
else
    echo "linux-syscall-support already exists, skipping clone"
fi

cd .. || { echo "failed to exit library path"; exit 1; }

generate_build_path "${library_path}"
if [[ -d ${build_path} ]]; then
    echo "Removing old build directory"
    rm -r ${build_path}
fi
mkdir -p ${build_path}
check_err_exit ${library_path} "Failed to create build directory"
cd ${build_path}
check_err_exit ${library_path} "Failed to enter build directory"

../../configure --prefix=`pwd` || { echo "ERROR: Breakpad configure failed!"; exit 1; }

# Build with C++17 (required for std::make_unique and std::string_view)
make CXXFLAGS="-std=c++17 ${CXX_FLAGS} -static-libgcc -static-libstdc++" CFLAGS="${C_FLAGS}" ${MAKE_OPTIONS} || {
    echo "ERROR: Breakpad compilation failed with C++17!"
    exit 1
}
make install
check_err_exit ${library_path} "Failed to install"
cd ../../../

# cmake_build ${library_path} -DCMAKE_C_FLAGS="-fPIC -I../../boringssl/include/" -DEVENT__DISABLE_TESTS=ON -DEVENT__DISABLE_OPENSSL=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo
# check_err_exit ${library_path} "Failed to build libevent!"
set_build_successful "${library_path}"
