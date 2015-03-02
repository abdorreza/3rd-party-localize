#!/bin/sh

if [ "$#" -ne 2 ]; then
        echo "Usage $0: lib_location install_location"
	exit
fi

NAVCHIPSDK_LIB_LOCATION=$1
NAVCHIPSDK_INSTALL_LOCATION=$2
# Cleanup navchipsdk install sandbox
rm -rf "$NAVCHIPSDK_INSTALL_LOCATION"
mkdir -p "$NAVCHIPSDK_INSTALL_LOCATION"

# Install gmock
cp "$NAVCHIPSDK_LIB_LOCATION/libNavChipSDK.a" "$NAVCHIPSDK_INSTALL_LOCATION"
