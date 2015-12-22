#!/bin/sh

if [ "$#" -ne 1 ]; then
        echo "Usage $0: build-script-dir [ios, android, macosx, linux-gcc, linux-gcc-4.9.2, linux-llvm]"
        echo "Example $0 ~/3rd-party-localize/build-scripts/ android"
        exit
fi

REPO_ROOT="$(pwd)"
PLATFORM_NAME="$1"
echo "Build project for platform $PLATFORM_NAME"

echo "cmake toolchain path $REPO_ROOT/cmake"
export CMAKE_LOCALIZE_TOOLS_DIR="$REPO_ROOT/cmake"

# msgpack-c
/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" msgpack-c msgpack $PLATFORM_NAME
if [ "$?" != "0" ]; then
  echo "build-cmake-projects.sh msgpack-c failed"
  exit 1
fi
# gmock
/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" gmock-1.7.0 gmock $PLATFORM_NAME
if [ "$?" != "0" ]; then
  echo "build-cmake-projects.sh gmock failed"
  exit 1
fi
# PBMLIB
/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" PBMLIB pbmlib $PLATFORM_NAME
if [ "$?" != "0" ]; then
  echo "build-cmake-projects.sh PBMLIB failed"
  exit 1
fi
# Intell tbb
/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" intel_tbb_42_20140601oss tbb $PLATFORM_NAME
if [ "$?" != "0" ]; then
  echo "build-cmake-projects.sh tbb failed"
  exit 1
fi

# ViSensor
if [ "$PLATFORM_NAME" = "macosx" ]; then
	/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" libvisensor visensor $PLATFORM_NAME
	if [ "$?" != "0" ]; then
  		echo "build-cmake-projects.sh libvisensor failed"
		exit 1
	fi
else
	echo "libvisensor won't build for $PLATFORM_NAME"
fi

# NavChipSDK
if [ "$PLATFORM_NAME" = "macosx" ]; then
	/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" NavChipSDK NavChipSDK $PLATFORM_NAME
	if [ "$?" != "0" ]; then
  		echo "build-cmake-projects.sh NavChipSDK failed"
		exit 1
	fi
else
	echo "NavChipSDK won't build for $PLATFORM_NAME"
fi

# libgeos
if [ "$PLATFORM_NAME" = "macosx" ] || [ "$PLATFORM_NAME" = "linux-gcc" ] || [ "$PLATFORM_NAME" = "linux-gcc-4.9.2" ] || [ "$PLATFORM_NAME" = "linux-llvm" ]; then
	/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" libgeos-svn-3.4 geos $PLATFORM_NAME
	if [ "$?" != "0" ]; then
  		echo "build-cmake-projects.sh libgeos-svn-3 failed"
		exit 1
	fi
else
	echo "libgeos won't build for $PLATFORM_NAME"
fi

# licxsparse
if [ "$PLATFORM_NAME" = "macosx" ] || [ "$PLATFORM_NAME" = "linux-gcc" ] || [ "$PLATFORM_NAME" = "linux-gcc-4.9.2" ] || [ "$PLATFORM_NAME" = "linux-llvm" ]; then
	/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" CXSparse cxsparse $PLATFORM_NAME 
	if [ "$?" != "0" ]; then
  		echo "build-cmake-projects.sh cxsparce failed"
		exit 1
	fi
else
	echo "libceres-solver won't build for $PLATFORM_NAME"
fi

# libceres-solver
if [ "$PLATFORM_NAME" = "macosx" ] || [ "$PLATFORM_NAME" = "linux-gcc" ] || [ "$PLATFORM_NAME" = "linux-gcc-4.9.2" ] || [ "$PLATFORM_NAME" = "linux-llvm" ]; then
	/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" ceres-solver-1.11.0 ceres $PLATFORM_NAME "-DMINIGLOG=ON -DGFLAGS=OFF -DSUITESPARSE=OFF -DCXSPARSE=ON -DLAPACK=OFF -DEIGENSPARSE=ON -DDISABLE_WFORMAT=ON -DCMAKE_PREFIX_PATH=$REPO_ROOT/eigen-3.2.5;$REPO_ROOT/install/cxsparse/include/cxsparse"
	if [ "$?" != "0" ]; then
  		echo "build-cmake-projects.sh ceres failed"
		exit 1
	fi
else
	echo "libceres-solver won't build for $PLATFORM_NAME"
fi

# Pangolin
if [ "$PLATFORM_NAME" = "macosx" ]; then
	/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" Pangolin pangolin $PLATFORM_NAME "-DCPP11_NO_BOOST=ON -DBUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_PANGOLIN_VIDEO=OFF"
	if [ "$?" != "0" ]; then
  		echo "build-cmake-projects.sh Pangolin failed"
		exit 1
	fi
else
	echo "Pangolin won't build for $PLATFORM_NAME"
fi

# SceneGraph
if [ "$PLATFORM_NAME" = "macosx" ]; then
	/bin/sh "$REPO_ROOT/build-scripts/build-cmake-projects.sh" SceneGraph SceneGraph $PLATFORM_NAME "-DEXPORT_SceneGraph=OFF -DBUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=OFF -DCMAKE_PREFIX_PATH=$REPO_ROOT/eigen-3.2.5;$REPO_ROOT/install/pangolin;$REPO_ROOT/install/pangolin/platform-include/macosx;$REPO_ROOT/install/pangolin/lib/macosx"

	if [ "$?" != "0" ]; then
  		echo "build-cmake-projects.sh SceneGraph failed"
		exit 1
	fi
else
	echo "SceneGraph won't build for $PLATFORM_NAME"
fi
