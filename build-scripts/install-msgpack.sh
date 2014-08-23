#!/bin/sh

if [ "$#" -ne 2 ]; then
        echo "Usage $0: lib_location install_location"
	exit
fi

GMOCK_LIB_LOCATION=$1
GMOCK_INSTALL_LIB_LOCATION=$2
GMOCK_INSTALL_INCLUDE_LOCATION="$GMOCK_INSTALL_LIB_LOCATION/../../include"

# Cleanup gmock install sandbox
rm -rf "$GMOCK_INSTALL_LIB_LOCATION"
rm -rf "$GMOCK_INSTALL_INCLUDE_LOCATION"

mkdir -p "$GMOCK_INSTALL_LIB_LOCATION"
mkdir -p "$GMOCK_INSTALL_INCLUDE_LOCATION"

# Install gmock
cp "$GMOCK_LIB_LOCATION/libmsgpack.a" "$GMOCK_INSTALL_LIB_LOCATION"
cp "$GMOCK_LIB_LOCATION/src/msgpack/version.h" "$GMOCK_INSTALL_INCLUDE_LOCATION"
