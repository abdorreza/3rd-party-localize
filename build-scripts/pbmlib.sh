#!/bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage $0: [ios, android, macosx, linux-gcc, linux-llvm]"
  exit 
fi

# Define gmock working env.
PBMLIB_LOCATION="PBMLIB"
PBMLIB_BUILD_LOCATION="build/PBMLIB"
PBMLIB_INSTALL_LOCATION="install/PBMLIB"

PLATFORM_NAME=$1

# Cleanup gmock build sandbox
rm -rf "$PBMLIB_BUILD_LOCATION"
mkdir -p "$PBMLIB_BUILD_LOCATION"

# Cleanup gmock install sandbox
rm -rf "$PBMLIB_INSTALL_LOCATION"
mkdir -p "$PBMLIB_INSTALL_LOCATION/include/PBM"
mkdir -p "$PBMLIB_INSTALL_LOCATION/lib/$PLATFORM_NAME"

# Build gmock
cd "$PBMLIB_BUILD_LOCATION"
echo $(pwd)
cmake "-DCMAKE_TOOLCHAIN_FILE=../../../localize/cmake/toolchain/$PLATFORM_NAME.toolchain.cmake" "-DDISABLE_WERROR=1" "../../$PBMLIB_LOCATION"
make -j8

# Install pbmlib 
cp "libPBMLIB.a" "../../$PBMLIB_INSTALL_LOCATION/lib/$PLATFORM_NAME/libpbmpak.a"
cp "../../$PBMLIB_LOCATION/pbmlib.h" "../../$PBMLIB_INSTALL_LOCATION/include/PBM/pbmpak.h"
