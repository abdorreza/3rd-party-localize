#!/bin/sh

if [ "$#" -ne 1 ]; then
  exit 
fi

# Define gmock working env.
GMOCK_LOCATION="gmock-1.7.0"
GMOCK_BUILD_LOCATION="build/gmock"
GMOCK_INSTALL_LOCATION="install/gmock"

PLATFORM_NAME=$1

# Cleanup gmock build sandbox
rm -rf "$GMOCK_BUILD_LOCATION"
mkdir -p "$GMOCK_BUILD_LOCATION"

# Cleanup gmock install sandbox
rm -rf "$GMOCK_INSTALL_LOCATION"
mkdir -p "$GMOCK_INSTALL_LOCATION/include/gmock"
mkdir -p "$GMOCK_INSTALL_LOCATION/include/gtest"
mkdir -p "$GMOCK_INSTALL_LOCATION/lib/$PLATFORM_NAME/"

# Build gmock
cd "$GMOCK_BUILD_LOCATION"
echo $(pwd)
cmake "-DCMAKE_TOOLCHAIN_FILE=../../../localize/cmake/toolchain/$PLATFORM_NAME.toolchain.cmake" "-DDISABLE_WERROR=1" "../../$GMOCK_LOCATION"
make -j8

# Install gmock
cp "libgmock.a" "../../$GMOCK_INSTALL_LOCATION/lib/$PLATFORM_NAME/"
cp "gtest/libgtest.a" "../../$GMOCK_INSTALL_LOCATION/lib/$PLATFORM_NAME/"
cp "../../$GMOCK_LOCATION/fused-src/gmock/gmock.h" "../../$GMOCK_INSTALL_LOCATION/include/gmock"
cp "../../$GMOCK_LOCATION/fused-src/gtest/gtest.h" "../../$GMOCK_INSTALL_LOCATION/include/gtest"
