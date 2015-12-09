#!/bin/sh

if [ "$#" -lt 5 ]; then
        echo "Usage $0: project_location project_build_location header_install_location lib_install_location platform_header_install_location"
	exit
fi

PROJECT_LOCATION=$1
LIB_LOCATION=$2
HEADER_INSTALL_LOCATION=$3
LIB_INSTALL_LOCATION=$4
PLATFORM_HEADER_INSTALL_LOCATION=$5

# Cleanup gmock install sandbox
rm -rf "$HEADER_INSTALL_LOCATION"
rm -rf "$PLATFORM_HEADER_INSTALL_LOCATION"
rm -rf "$LIB_INSTALL_LOCATION"
mkdir -p "$HEADER_INSTALL_LOCATION"
mkdir -p "$PLATFORM_HEADER_INSTALL_LOCATION"
mkdir -p "$LIB_INSTALL_LOCATION"

# Install gmock
cp "$LIB_LOCATION/lib/libgeos.a" "$LIB_INSTALL_LOCATION"
cp -R "$PROJECT_LOCATION/include/geos" "$HEADER_INSTALL_LOCATION"
cp -R "$LIB_LOCATION/include/geos" "$PLATFORM_HEADER_INSTALL_LOCATION"
