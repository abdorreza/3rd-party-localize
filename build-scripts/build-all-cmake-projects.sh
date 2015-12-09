#!/bin/sh

if [ "$#" -ne 1 ]; then
        echo "Usage $0: build-script-dir [ios, android, macosx, linux-gcc, linux-gcc4.9, linux-llvm]"
        echo "Example $0 ~/3rd-party-localize/build-scripts/ android"
        exit
fi

REPO_ROOT="$(pwd)"
PLATFORM_NAME=$1
echo "Build project for platform $2"


echo "cmake toolchain path $REPO_ROOT/cmake"
export CMAKE_LOCALIZE_TOOLS_DIR="$REPO_ROOT/cmake"

# msgpack-c
/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" msgpack-c msgpack $PLATFORM_NAME
# gmock
/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" gmock-1.7.0 gmock $PLATFORM_NAME
# PBMLIB
/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" PBMLIB pbmlib $PLATFORM_NAME
# Intell tbb
/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" intel_tbb_42_20140601oss tbb $PLATFORM_NAME

# ViSensor
if [ "$PLATFORM_NAME" == "macosx" ]; then
	/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" libvisensor visensor $PLATFORM_NAME
else
	echo "libvisensor won't build for $PLATFORM_NAME"
fi

# NavChipSDK
if [ "$PLATFORM_NAME" == "macosx" ]; then
	/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" NavChipSDK NavChipSDK $PLATFORM_NAME
else
	echo "NavChipSDK won't build for $PLATFORM_NAME"
fi

# libgeos
if [ "$PLATFORM_NAME" == "macosx" ] || [ "$PLATFORM_NAME" == "linux" ] || [ "$PLATFORM_NAME" == "linux-gcc4.9" ] || [ "$PLATFORM_NAME" == "linux-llvm" ]; then
	/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" libgeos-svn-3.4 geos $PLATFORM_NAME
else
	echo "libgeos won't build for $PLATFORM_NAME"
fi

# libceres-solver
if [ "$PLATFORM_NAME" == "macosx" ] || [ "$PLATFORM_NAME" == "linux" ] || [ "$PLATFORM_NAME" == "linux-gcc4.9" ] || [ "$PLATFORM_NAME" == "linux-llvm" ]; then
	/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" ceres-solver-1.11.0 ceres $PLATFORM_NAME "-DMINIGLOG=ON -DGFLAGS=OFF -DSUITESPARSE=OFF -DCXSPARSE=OFF -DEIGENSPARSE=ON -DDISABLE_WFORMAT=ON -DCMAKE_PREFIX_PATH=$REPO_ROOT/eigen-3.2.5"
else
	echo "libceres-solver won't build for $PLATFORM_NAME"
fi
