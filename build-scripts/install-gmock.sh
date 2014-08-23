#!/bin/sh

if [ "$#" -ne 2 ]; then
        echo "Usage $0: lib_location install_location"
	exit
fi

GMOCK_LIB_LOCATION=$1
GMOCK_INSTALL_LOCATION=$2
# Cleanup gmock install sandbox
rm -rf "$GMOCK_INSTALL_LOCATION"
mkdir -p "$GMOCK_INSTALL_LOCATION"

# Install gmock
cp "$GMOCK_LIB_LOCATION/libgmock.a" "$GMOCK_INSTALL_LOCATION"
cp "$GMOCK_LIB_LOCATION/gtest/libgtest.a" "$GMOCK_INSTALL_LOCATION"
