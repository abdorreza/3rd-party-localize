#!/bin/sh

if [ "$#" -ne 1 ]; then
        echo "Usage $0: [ios, android, macosx, linux-gcc, linux-gcc4.9, linux-llvm]" 
        echo "Example $0: macosx"
        exit
fi

INSTALL_LOCATION="install/boost/"
PLATFORM_NAME=$1

REPO_ROOT="$(pwd)"
SRC_DIR=$1
TEMP_DIR="$REPO_ROOT/boost_$PLATFORM_NAME""_build"

mkdir -p $TEMP_DIR

mkdir -p $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/

if [ "$PLATFORM_NAME" == "macosx" ]; then
	cd "$TEMP_DIR"
	sh "../build-scripts/boost_apple.sh"
	cp $PLATFORM_NAME/build/x86_64/libboost_system.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp $PLATFORM_NAME/build/x86_64/libboost_serialization.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp $PLATFORM_NAME/build/x86_64/libboost_program_options.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp $PLATFORM_NAME/build/x86_64/libboost_filesystem.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp $PLATFORM_NAME/build/x86_64/libboost_thread.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
elif [ "$PLATFORM_NAME" == "ios" ]; then
	cd "$TEMP_DIR"
	sh "../build-scripts/boost_apple.sh"
	cp $PLATFORM_NAME/build/x86_64/libboost_system.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp $PLATFORM_NAME/build/x86_64/libboost_serialization.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp $PLATFORM_NAME/build/x86_64/libboost_program_options.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp $PLATFORM_NAME/build/x86_64/libboost_filesystem.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp $PLATFORM_NAME/build/x86_64/libboost_thread.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
elif [ "$PLATFORM_NAME" == "android" ]; then
	cd "$TEMP_DIR"
	sh "../build-scripts/boost_android.sh"
	cp src/boost_1_56_0/android-build/stage/lib/libboost_system.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp src/boost_1_56_0/android-build/stage/lib/libboost_serialization.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp src/boost_1_56_0/android-build/stage/lib/libboost_program_options.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp src/boost_1_56_0/android-build/stage/lib/libboost_filesystem.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp src/boost_1_56_0/android-build/stage/lib/libboost_thread.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
elif [ "$PLATFORM_NAME" == "linux-gcc" ]; then
	cd "$TEMP_DIR"
	sh "../build-scripts/boost_linux.sh"
	cp src/boost_1_56_0/android-build/stage/lib/libboost_system.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp src/boost_1_56_0/android-build/stage/lib/libboost_serialization.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp src/boost_1_56_0/android-build/stage/lib/libboost_program_options.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp src/boost_1_56_0/android-build/stage/lib/libboost_filesystem.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
	cp src/boost_1_56_0/android-build/stage/lib/libboost_thread.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
fi
