#!/bin/sh

if [ "$#" -ne 2 ]; then
        echo "Usage $0: build-script-dir [ios, android, macosx, linux-gcc, linux-llvm]"
        echo "Example $0:  ~/3rd-party-localize/build-scripts/ android"
        exit
fi

REPO_ROOT="$(pwd)"
SCRIPTS_DIR=$1
PLATFORM_NAME=$2
echo "Build project for platform $2"

/bin/sh $SCRIPTS_DIR/build-cmake-projects.sh msgpack-c msgpack $PLATFORM_NAME ;
/bin/sh $SCRIPTS_DIR/build-cmake-projects.sh NavChipSDK NavChipSDK $PLATFORM_NAME ;
/bin/sh $SCRIPTS_DIR/gmock.sh $PLATFORM_NAME ;
