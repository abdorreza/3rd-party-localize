#!/bin/sh

# Define gmock working env.
GMOCK_LOCATION="gmock-1.7.0"
GMOCK_BUILD_LOCATION="build/gmock"
GMOCK_INSTALL_LOCATION="install/gmock"

# Cleanup gmock build sandbox
rm -rf "$GMOCK_BUILD_LOCATION"
mkdir -p "$GMOCK_BUILD_LOCATION"

# Cleanup gmock install sandbox
rm -rf "$GMOCK_INSTALL_LOCATION"
mkdir -p "$GMOCK_INSTALL_LOCATION/include"
mkdir -p "$GMOCK_INSTALL_LOCATION/lib"

# Build gmock
cd "$GMOCK_BUILD_LOCATION"
echo $(pwd)
cmake "-DCMAKE_TOOLCHAIN_FILE=../../cmake/toolchain/macosx.toolchain.cmake" "../../$GMOCK_LOCATION"
make -j8

# Install gmock
cp "libgmock.a" "../../$GMOCK_INSTALL_LOCATION/lib"
cp "gtest/libgtest.a" "../../$GMOCK_INSTALL_LOCATION/lib"
cp "../../$GMOCK_LOCATION/fused-src/gmock/gmock.h" "../../$GMOCK_INSTALL_LOCATION/include"
cp "../../$GMOCK_LOCATION/fused-src/gtest/gtest.h" "../../$GMOCK_INSTALL_LOCATION/include"
