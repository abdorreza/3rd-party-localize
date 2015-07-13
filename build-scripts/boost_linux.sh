#!/bin/sh
# Builds a Boost framework for the Linux.
#
# To configure the script, define:
#    BOOST_LIBS:        which libraries to build
#
# Then go get the source tar.bz of the boost you want to build, shove it in the
# same directory as this script, and run "./boost.sh". Grab a cuppa. And voila.
#===============================================================================

# Include config and common functions
SCRIPTPATH="$(dirname $0)/boost_config.sh"
echo "$SCRIPTPATH"
source $SCRIPTPATH

: ${PREFIXDIR:=`pwd`/linux/prefix}
: ${BUILDDIR:=`pwd`/linux/build}
: ${TARGET_TOOLSET}:="$1"

BOOST_TARBALL=$TARBALLDIR/boost_$BOOST_VERSION2.tar.bz2
BOOST_SRC=$SRCDIR/boost_${BOOST_VERSION2}

#===============================================================================

cleanEverythingReadyToStart()
{
    echo Cleaning everything before we start to build...

    rm -rf linux-build
    rm -rf $BUILDDIR

    doneSection
}

#===============================================================================

buildBoostForLinux()
{
    cd $BOOST_SRC

    echo Building Boost for Linux
    # Install this one so we can copy the includes for the frameworks...
    ./b2 -j16 --without-python --build-dir=linux-build --stagedir=linux-build/stage --prefix=$PREFIXDIR toolset=TARGET_TOOLSET target-os=linux threading=multi link=static runtime-link=static variant=release stage
    doneSection
}


#===============================================================================
# Execution starts here
#===============================================================================

mkdir -p $BUILDDIR

cleanEverythingReadyToStart #may want to comment if repeatedly running during dev

echo "NDK_ROOT:          $NDK_ROOT"
echo "BOOST_VERSION:     $BOOST_VERSION"
echo "BOOST_LIBS:        $BOOST_LIBS"
echo "BOOST_SRC:         $BOOST_SRC"
echo "BUILDDIR:   		 $BUILDDIR"
echo "PREFIXDIR:         $PREFIXDIR"
echo

downloadBoost
unpackBoost
bootstrapBoost
buildBoostForLinux

echo "Completed successfully"

#===============================================================================
