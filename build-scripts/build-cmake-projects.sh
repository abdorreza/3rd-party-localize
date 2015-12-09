#!/bin/sh

if [ "$#" -lt 3 ]; then
        echo "Usage $0: location name [ios, android, macosx, linux-gcc, linux-gcc4.9, linux-llvm]"
        echo "Example $0: gmock-1.7.0 gmock android [CMAKE_FLAGS]"
        exit
fi

REPO_ROOT="$(pwd)"
PROJECT_LOCATION="$REPO_ROOT/$1"
PROJECT_NAME=$2
PLATFORM_NAME=$3
CMAKE_FLAGS=$4

echo "Build project from $1 as $2 for platform $3"

# Define project working env.
PROJECT_BUILD_LOCATION="$REPO_ROOT/build/$PROJECT_NAME/$PLATFORM_NAME"
PROJECT_LIB_INSTALL_LOCATION="$REPO_ROOT/install/$PROJECT_NAME/lib/$PLATFORM_NAME"
PROJECT_HEADER_INSTALL_LOCATION="$REPO_ROOT/install/$PROJECT_NAME/include"
PROJECT_PLATFORM_HEADER_INSTALL_LOCATION="$REPO_ROOT/install/$PROJECT_NAME/platform-include/$PLATFORM_NAME"

# Cleanup project build sandbox
rm -rf "$PROJECT_BUILD_LOCATION"
mkdir -p "$PROJECT_BUILD_LOCATION"

# Build gmock
cd "$PROJECT_BUILD_LOCATION"
echo $(pwd)
cmake -DCMAKE_BUILD_TYPE=Release "-DCMAKE_TOOLCHAIN_FILE=$CMAKE_LOCALIZE_TOOLS_DIR/toolchain/$PLATFORM_NAME.toolchain.cmake" $CMAKE_FLAGS "-DDISABLE_WERROR=1" "$PROJECT_LOCATION"
make -j8 VERBOSE=1

# Install artifacts
PROJECT_LIB_LOCATION="$PROJECT_BUILD_LOCATION"
/bin/sh "$REPO_ROOT/build-scripts/install-scripts/install-$PROJECT_NAME.sh" "$PROJECT_LOCATION" "$PROJECT_LIB_LOCATION" "$PROJECT_HEADER_INSTALL_LOCATION" "$PROJECT_LIB_INSTALL_LOCATION" "$PROJECT_PLATFORM_HEADER_INSTALL_LOCATION"
