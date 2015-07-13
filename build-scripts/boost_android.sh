#!/bin/sh
# Builds a Boost framework for the Android.
#
# To configure the script, define:
#    BOOST_LIBS:        which libraries to build
#
# Then go get the source tar.bz of the boost you want to build, shove it in the
# same directory as this script, and run "./boost.sh". Grab a cuppa. And voila.
#===============================================================================

: ${BOOST_VERSION:=1.56.0}
: ${BOOST_VERSION2:=1_56_0}

: ${BOOST_LIBS:="atomic chrono date_time exception filesystem program_options random signals system test thread serialization"}

: ${TARBALLDIR:=`pwd`}
: ${SRCDIR:=`pwd`/src}
: ${PREFIXDIR:=`pwd`/android/prefix}
: ${ANDROIDBUILDDIR:=`pwd`/android/build}

BOOST_TARBALL=$TARBALLDIR/boost_$BOOST_VERSION2.tar.bz2
BOOST_SRC=$SRCDIR/boost_${BOOST_VERSION2}

#===============================================================================
# Functions
#===============================================================================

abort()
{
    echo
    echo "Aborted: $@"
    exit 1
}

doneSection()
{
    echo
    echo "================================================================="
    echo "Done"
    echo
}

#===============================================================================

cleanEverythingReadyToStart()
{
    echo Cleaning everything before we start to build...

    rm -rf android-build
    rm -rf $ANDROIDBUILDDIR

    doneSection
}

#===============================================================================

downloadBoost()
{
    if [ ! -s $TARBALLDIR/boost_${BOOST_VERSION2}.tar.bz2 ]; then
        echo "Downloading boost ${BOOST_VERSION}"
        curl -L -o $TARBALLDIR/boost_${BOOST_VERSION2}.tar.bz2 http://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/boost_${BOOST_VERSION2}.tar.bz2/download
    fi

    doneSection
}

#===============================================================================

unpackBoost()
{
    [ -f "$BOOST_TARBALL" ] || abort "Source tarball missing."

    echo Unpacking boost into $SRCDIR...

    [ -d $SRCDIR ]    || mkdir -p $SRCDIR
    [ -d $BOOST_SRC ] || ( cd $SRCDIR; tar xfj $BOOST_TARBALL )
    [ -d $BOOST_SRC ] && echo "    ...unpacked as $BOOST_SRC"

    doneSection
}

#===============================================================================

restoreBoost()
{
    cp $BOOST_SRC/tools/build/src/user-config.jam-bk $BOOST_SRC/tools/build/src/user-config.jam
}

#===============================================================================

updateBoost()
{
    echo Updating boost into $BOOST_SRC...

    cp $BOOST_SRC/tools/build/src/user-config.jam $BOOST_SRC/tools/build/src/user-config.jam-bk

    cat >> $BOOST_SRC/tools/build/src/user-config.jam <<EOF
import os ;  
  using gcc : android :  
    ${NDK_ROOT}/toolchains/arm-linux-androideabi-4.8/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-g++ :  
    <compileflags>--sysroot=${NDK_ROOT}/platforms/android-19/arch-arm  
    <compileflags>-fexceptions
    <compileflags>-frtti
    <compileflags>-fpic
    <compileflags>-ffunction-sections
    <compileflags>-funwind-tables
    <compileflags>-Wno-psabi
    <compileflags>-march=armv7-a
    <compileflags>-msoft-float
    <compileflags>-mfpu=neon
    <compileflags>-fvisibility=hidden
    <compileflags>-fvisibility-inlines-hidden
    <compileflags>-fdata-sections
    <linkflags>-march=armv7-a
    <linkflags>-Wl,--fix-cortex-a8
    <compileflags>-mthumb  
    <compileflags>-O3  
    <compileflags>-fno-strict-aliasing  
    <compileflags>-O2  
    <compileflags>-DNDEBUG  
    <compileflags>-g  
    <compileflags>-lstdc++  
    <compileflags>-I${NDK_ROOT}/sources/cxx-stl/gnu-libstdc++/4.8/include  
    <compileflags>-I${NDK_ROOT}/sources/cxx-stl/gnu-libstdc++/4.8/libs/armeabi/include  
    <compileflags>-D__GLIBC__   
    <compileflags>-D__arm__  
    <archiver>${NDK_ROOT}/toolchains/arm-linux-androideabi-4.8/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-ar  
    <ranlib>${NDK_ROOT}/toolchains/arm-linux-androideabi-4.8/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-ranlib  
      ;
EOF

    doneSection
}

#===============================================================================

bootstrapBoost()
{
    cd $BOOST_SRC

    BOOST_LIBS_COMMA=$(echo $BOOST_LIBS | sed -e "s/ /,/g")
    echo "Bootstrapping (with libs $BOOST_LIBS_COMMA)"
    ./bootstrap.sh --with-libraries=$BOOST_LIBS_COMMA

    doneSection
}

#===============================================================================

buildBoostForAndroid()
{
    cd $BOOST_SRC

    echo Building Boost for Android
    # Install this one so we can copy the includes for the frameworks...
    ./b2 -j16 --without-python --build-dir=android-build --stagedir=android-build/stage --prefix=$PREFIXDIR toolset=gcc-android target-os=linux threading=multi link=static runtime-link=static variant=release stage
    doneSection
}


#===============================================================================
# Execution starts here
#===============================================================================

mkdir -p $ANDROIDBUILDDIR

cleanEverythingReadyToStart #may want to comment if repeatedly running during dev
restoreBoost

echo "NDK_ROOT:          $NDK_ROOT"
echo "BOOST_VERSION:     $BOOST_VERSION"
echo "BOOST_LIBS:        $BOOST_LIBS"
echo "BOOST_SRC:         $BOOST_SRC"
echo "ANDROIDBUILDDIR:   $ANDROIDBUILDDIR"
echo "PREFIXDIR:         $PREFIXDIR"
echo

downloadBoost
unpackBoost
bootstrapBoost
updateBoost
buildBoostForAndroid

restoreBoost

echo "Completed successfully"

#===============================================================================