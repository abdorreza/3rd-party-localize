#!/bin/bash

if [ "$#" -ne 1 ]; then
        echo "Usage $0: [ios, android, macosx, linux-gcc, linux-gcc4.9, linux-llvm]" 
        echo "Example $0: macosx"
        exit
fi

INSTALL_LOCATION="install/boost/"
PLATFORM_NAME="$1"

REPO_ROOT="$(pwd)"
SRC_DIR=$1
TEMP_DIR="$REPO_ROOT/build/boost_$PLATFORM_NAME""_build"

mkdir -p "$TEMP_DIR"

mkdir -p "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/"
mkdir -p "$REPO_ROOT/install/boost/include"

if [ "$PLATFORM_NAME" == "macosx" ]; then
	cd "$TEMP_DIR"
	sh "$REPO_ROOT/build-scripts/boost-build-scripts/boost_apple.sh"
	cp src/*/macosx-build/stage/lib/libboost_system.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/macosx-build/stage/lib/libboost_serialization.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/macosx-build/stage/lib/libboost_wserialization.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/macosx-build/stage/lib/libboost_program_options.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/"
	cp src/*/macosx-build/stage/lib/libboost_filesystem.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/"
	cp src/*/macosx-build/stage/lib/libboost_thread.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/"
	cp -r src/*/boost "$REPO_ROOT/install/boost/include/"
elif [ "$PLATFORM_NAME" == "ios" ]; then
	cd "$TEMP_DIR"
	sh "$REPO_ROOT/build-scripts/boost-build-scripts/boost_apple.sh"
	cp src/*/iphone-build/stage/lib/libboost_system.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/iphone-build/stage/lib/libboost_serialization.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/iphone-build/stage/lib/libboost_wserialization.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/iphone-build/stage/lib/libboost_program_options.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/iphone-build/stage/lib/libboost_filesystem.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/iphone-build/stage/lib/libboost_thread.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp -r src/*/boost "$REPO_ROOT/install/boost/include/"
elif [ "$PLATFORM_NAME" == "android" ]; then
	cd "$TEMP_DIR"
	sh "$REPO_ROOT/build-scripts/boost-build-scripts/boost_android.sh"
	cp src/*/android-build/stage/lib/libboost_system.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/android-build/stage/lib/libboost_serialization.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/android-build/stage/lib/libboost_wserialization.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/android-build/stage/lib/libboost_program_options.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/android-build/stage/lib/libboost_filesystem.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/android-build/stage/lib/libboost_thread.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp -r src/*/boost "$REPO_ROOT/install/boost/include/"
elif [ "$PLATFORM_NAME" == "linux-gcc" ]; then
	cd "$TEMP_DIR"
	sh "$REPO_ROOT/build-scripts/boost-build-scripts/boost_linux.sh" "gcc"
	cp src/*/linux-build/stage/lib/libboost_system.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_serialization.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/"
	cp src/*/linux-build/stage/lib/libboost_wserialization.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/"
	cp src/*/linux-build/stage/lib/libboost_program_options.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_filesystem.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_thread.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp -r src/*/boost "$REPO_ROOT/install/boost/include/"
elif [ "$PLATFORM_NAME" == "linux-gcc4.9" ]; then
	cd "$TEMP_DIR"
	sh "$REPO_ROOT/build-scripts/boost-build-scripts/boost_linux.sh" "gcc-4.9"
	cp src/*/linux-build/stage/lib/libboost_system.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_serialization.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_wserialization.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_program_options.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_filesystem.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_thread.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp -r src/*/boost "$REPO_ROOT/install/boost/include/"
elif [ "$PLATFORM_NAME" == "linux-llvm" ]; then
	cd "$TEMP_DIR"
	sh "$REPO_ROOT/build-scripts/boost-build-scriptsts/boost_linux.sh" "clang"
	cp src/*/linux-build/stage/lib/libboost_system.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_serialization.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_wserialization.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_program_options.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_filesystem.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp src/*/linux-build/stage/lib/libboost_thread.a "$REPO_ROOT/install/boost/lib/$PLATFORM_NAME/" 
	cp -r src/*/boost "$REPO_ROOT/install/boost/include/"
fi
