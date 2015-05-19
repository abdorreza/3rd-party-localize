#!/bin/sh

# Define TBB working env.
TBB_LOCATION="intel_tbb_42_20140601oss"
TBB_BUILD_LOCATION="build/tbb"
TBB_INSTALL_LOCATION="install/tbb"

# Cleanup TBB build sandbox
rm -rf "$TBB_BUILD_LOCATION"
mkdir -p "$TBB_BUILD_LOCATION"

# Cleanup TBB install sandbox
rm -rf "$TBB_INSTALL_LOCATION"
mkdir -p "$TBB_INSTALL_LOCATION/include/tbb"
mkdir -p "$TBB_INSTALL_LOCATION/include/serial"
mkdir -p "$TBB_INSTALL_LOCATION/lib"

# Build TBB
cd "$TBB_BUILD_LOCATION"
echo $(pwd)
cmake "-DCMAKE_TOOLCHAIN_FILE=../../../localize/cmake/toolchain/macosx.toolchain.cmake" "-DDISABLE_WERROR=1" "../../$TBB_LOCATION"
make -j8

# Install TBB
cp "libtbb.a" "../../$TBB_INSTALL_LOCATION/lib"
cp -rf "../../$TBB_LOCATION/include/serial" "../../$TBB_INSTALL_LOCATION/include"
cp -rf "../../$TBB_LOCATION/include/tbb" "../../$TBB_INSTALL_LOCATION/include"
