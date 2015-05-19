#!/bin/sh

# Define gmock working env.
PBMLIB_LOCATION="PBMLIB"
PBMLIB_BUILD_LOCATION="build/PBMLIB"
PBMLIB_INSTALL_LOCATION="install/PBMLIB"

# Cleanup gmock build sandbox
rm -rf "$PBMLIB_BUILD_LOCATION"
mkdir -p "$PBMLIB_BUILD_LOCATION"

# Cleanup gmock install sandbox
rm -rf "$PBMLIB_INSTALL_LOCATION"
mkdir -p "$PBMLIB_INSTALL_LOCATION/include/PBM"
mkdir -p "$PBMLIB_INSTALL_LOCATION/lib"

# Build gmock
cd "$PBMLIB_BUILD_LOCATION"
echo $(pwd)
cmake "-DCMAKE_TOOLCHAIN_FILE=../../../localize/cmake/toolchain/macosx.toolchain.cmake" "-DDISABLE_WERROR=1" "../../$PBMLIB_LOCATION"
make -j8

# Install pbmlib 
cp "libPBMLIB.a" "../../$PBMLIB_INSTALL_LOCATION/lib/libpbmpak.a"
cp "../../$PBMLIB_LOCATION/pbmlib.h" "../../$PBMLIB_INSTALL_LOCATION/include/PBM/pbmpak.h"
