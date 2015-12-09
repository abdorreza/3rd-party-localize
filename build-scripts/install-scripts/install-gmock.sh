#!/bin/sh

if [ "$#" -lt 4 ]; then
        echo "Usage $0: project_location project_build_location header_install_location lib_install_location"
	exit
fi

GMOCK_PROJECT_LOCATION=$1
GMOCK_LIB_LOCATION=$2
GMOCK_HEADER_INSTALL_LOCATION=$3
GMOCK_LIB_INSTALL_LOCATION=$4
# Cleanup gmock install sandbox
rm -rf "$GMOCK_HEADER_INSTALL_LOCATION"
rm -rf "$GMOCK_LIB_INSTALL_LOCATION"
mkdir -p "$GMOCK_HEADER_INSTALL_LOCATION"
mkdir -p "$GMOCK_LIB_INSTALL_LOCATION"

# Install gmock
cp $GMOCK_LIB_LOCATION/libs/*/libgmock.a "$GMOCK_LIB_INSTALL_LOCATION"
cp $GMOCK_LIB_LOCATION/libs/*/libgtest.a "$GMOCK_LIB_INSTALL_LOCATION"
cp -R "$GMOCK_PROJECT_LOCATION/fused-src/gmock" "$GMOCK_HEADER_INSTALL_LOCATION/"
cp -R "$GMOCK_PROJECT_LOCATION/fused-src/gtest" "$GMOCK_HEADER_INSTALL_LOCATION/"
