#!/bin/sh

if [ "$#" -ne 3 ]; then
        echo "Usage $0: boost_src_dir temp_directory [ios, android, macosx, linux-gcc, linux-llvm]" 
        echo "Example $0: ~/3rd-party-localize/boost_1_55_0 /tmp/boost-build macosx"
        exit
fi

INSTALL_LOCATION="install/boost/"
PLATFORM_NAME=$3

REPO_ROOT="$(pwd)"
SRC_DIR=$1
TEMP_DIR=$2

mkdir -p $TEMP_DIR

cd $SRC_DIR
/bin/sh bootstrap.sh
$SRC_DIR/b2 install --prefix=$TEMP_DIR
 
mkdir -p $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/

cp $TEMP_DIR/lib/libboost_system.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
cp $TEMP_DIR/lib/libboost_serialization.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
cp $TEMP_DIR/lib/libboost_program_options.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
cp $TEMP_DIR/lib/libboost_filesystem.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
cp $TEMP_DIR/lib/libboost_wserialization.a $REPO_ROOT/install/boost/lib/$PLATFORM_NAME/ 
