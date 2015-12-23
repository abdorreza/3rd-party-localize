#!/bin/sh

if [ "$#" -lt 4 ]; then
        echo "Usage $0: project_location project_build_location header_install_location lib_install_location"
	exit
fi

PROJECT_LOCATION=$1
LIB_LOCATION=$2
HEADER_INSTALL_LOCATION=$3
LIB_INSTALL_LOCATION=$4
# Cleanup gmock install sandbox
rm -rf "$HEADER_INSTALL_LOCATION"
rm -rf "$LIB_INSTALL_LOCATION"
mkdir -p "$HEADER_INSTALL_LOCATION/GL"
mkdir -p "$LIB_INSTALL_LOCATION"

# Install gmock
cp $LIB_LOCATION/lib/libGLEW.a "$LIB_INSTALL_LOCATION"
cp -R "$PROJECT_LOCATION/include/GL/" "$HEADER_INSTALL_LOCATION/GL/"
