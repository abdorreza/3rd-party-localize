#!/bin/sh

if [ "$#" -lt 2 ]; then
        echo "Usage $0: lib_location install_location"
	exit
fi

GEOS_LIB_LOCATION=$1
GEOS_INSTALL_LOCATION=$2
GEOS_SRC_LOCATION=$3
GEOS_INSTALL_INCLUDE_LOCATION="$GEOS_INSTALL_LOCATION/../../include/"

# Cleanup gmock install sandbox
rm -rf "$GEOS_INSTALL_LOCATION"
mkdir -p "$GEOS_INSTALL_LOCATION"
echo "$GEOS_INSTALL_INCLUDE_LOCATION"
mkdir -p "$GEOS_INSTALL_INCLUDE_LOCATION"

# Install gmock
cp "$GEOS_LIB_LOCATION/lib/libgeos.a" "$GEOS_INSTALL_LOCATION"
echo "cp $GEOS_SRC_LOCATION/include/geos/* $GEOS_INSTALL_INCLUDE_LOCATION"
cp -R $GEOS_SRC_LOCATION/include/geos/* "$GEOS_INSTALL_INCLUDE_LOCATION" 
