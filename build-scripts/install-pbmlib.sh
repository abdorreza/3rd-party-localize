#!/bin/sh

if [ "$#" -ne 2 ]; then
        echo "Usage $0: lib_location install_location"
	exit
fi

PBMLIB_LIB_LOCATION=$1
PBMLIB_INSTALL_LOCATION=$2
# Cleanup gmock install sandbox
rm -rf "$PBMLIB_INSTALL_LOCATION"
mkdir -p "$PBMLIB_INSTALL_LOCATION"

# Install gmock
cp "$PBMLIB_LIB_LOCATION/libPBMLIB.a" "$PBMLIB_INSTALL_LOCATION"
