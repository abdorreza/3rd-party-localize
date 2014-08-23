#!/bin/sh

if [ "$#" -ne 2 ]; then
        echo "Usage $0: lib_location install_location"
	exit
fi

TBB_LIB_LOCATION=$1
TBB_INSTALL_LOCATION=$2
# Cleanup tbb install sandbox
rm -rf "$TBB_INSTALL_LOCATION"
mkdir -p "$TBB_INSTALL_LOCATION"

# Install tbb
cp "$TBB_LIB_LOCATION/libtbb.a" "$TBB_INSTALL_LOCATION/libpbmpak.a"
