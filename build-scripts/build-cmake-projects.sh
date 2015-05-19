#!/bin/sh

if [ "$#" -ne 3 ]; then
        echo "Usage $0: location name [ios, android, macosx, linux-gcc, linux-llvm]"
        echo "Example $0: gmock-1.7.0 gmock android"
        exit
fi

REPO_ROOT="$(pwd)"
PROJECT_LOCATION=$1
PROJECT_NAME=$2
PLATFORM_NAME=$3
echo "Build project from $1 as $2 for platform $3"

# Define project working env.
PROJECT_BUILD_LOCATION="build/$PROJECT_NAME/$PLATFORM_NAME"
PROJECT_INSTALL_LOCATION="$(pwd)/install/$PROJECT_NAME/lib/$PLATFORM_NAME"

# Cleanup project build sandbox
rm -rf "$PROJECT_BUILD_LOCATION"
mkdir -p "$PROJECT_BUILD_LOCATION"

# Build gmock
cd "$PROJECT_BUILD_LOCATION"
echo $(pwd)
cmake -DCMAKE_BUILD_TYPE=Release "-DCMAKE_TOOLCHAIN_FILE=../../../../localize/cmake/toolchain/$PLATFORM_NAME.toolchain.cmake" "../../../$PROJECT_LOCATION"
make -j8 VERBOSE=1

# Install artifacts
PROJECT_LIB_LOCATION="$(pwd)"
/bin/sh $REPO_ROOT/build-scripts/install-$PROJECT_NAME.sh $PROJECT_LIB_LOCATION $PROJECT_INSTALL_LOCATION "../../../$PROJECT_LOCATION" 
