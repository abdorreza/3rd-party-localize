# To cross compile for MacOSX:
# build$ cmake .. -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/macosx.toolchain.cmake

# This line brakes Makefile generation on cmake 3.0.
SET(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set (CMAKE_CROSSCOMPILING_TARGET DARWIN)
set (UNIX True)
set (APPLE True)
set (MACOSX True)

execute_process(COMMAND xcode-select -print-path
    OUTPUT_VARIABLE XCODE_SELECT OUTPUT_STRIP_TRAILING_WHITESPACE)

if(EXISTS ${XCODE_SELECT})
    set(DEVROOT "${XCODE_SELECT}/Platforms/MacOSX.platform/Developer")
    set(NEW_XCODE_LOCATION ON)
    if (NOT EXISTS "${DEVROOT}/SDKs/MacOSX${CMAKE_SYSTEM_VERSION}.sdk")
		file(GLOB INSTALLED_SDKS ${DEVROOT}/SDKs/*)
    set(CMAKE_SYSTEM_VERSION "10.6")
		foreach(SDK_VERSION ${INSTALLED_SDKS})
      string(REGEX MATCH "[0-9][0-9]\\.[0-9][0-9]?" EXTRACTED_SYSTEM_VERSION ${SDK_VERSION})
      if(${EXTRACTED_SYSTEM_VERSION} VERSION_GREATER ${CMAKE_SYSTEM_VERSION})
        set(CMAKE_SYSTEM_VERSION ${EXTRACTED_SYSTEM_VERSION})
      endif()
    endforeach()
	endif()
else()
  set(NEW_XCODE_LOCATION OFF)
        set(DEVROOT "/Developer/Platforms/MacOSX.platform/Developer")
endif()

message(STATUS "MacOSX SDK version:${CMAKE_SYSTEM_VERSION}")

set(CMAKE_OSX_ARCHITECTURES x86_64)
set(ARCHS "-arch x86_64")

# we have to use clang - llvm will choke on those __has_feature macros?
set (CMAKE_C_COMPILER "${XCODE_SELECT}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang")
set (CMAKE_CXX_COMPILER "${XCODE_SELECT}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++")
set (CMAKE_AR "${XCODE_SELECT}/Toolchains/XcodeDefault.xctoolchain/usr/bin/ar" CACHE FILEPATH "" FORCE)

if ($ENV{MACOSX_DEPLOYMENT_TARGET})
        message(FATAL_ERROR "llvm will croak with MACOSX_DEPLOYMENT_TARGET environment variable set when building for macosx - unset MACOSX_DEPLOYMENT_TARGET")
endif()

set(SDKROOT "${DEVROOT}/SDKs/MacOSX${CMAKE_SYSTEM_VERSION}.sdk")
set(CMAKE_OSX_SYSROOT "${SDKROOT}")

# force compiler and linker flags
set(CMAKE_C_LINK_FLAGS ${ARCHS})
set(CMAKE_CXX_LINK_FLAGS ${ARCHS})
ADD_DEFINITIONS(${ARCHS})
ADD_DEFINITIONS("--sysroot=${SDKROOT}")

# headers
INCLUDE_DIRECTORIES(SYSTEM "${SDKROOT}/usr/include")

# libraries
LINK_DIRECTORIES("${SDKROOT}/usr/lib/system")
LINK_DIRECTORIES("${SDKROOT}/usr/lib")

#######################################################
# Config
#######################################################

if (NOT DEFINED ENV{CMAKE_LOCALIZE_TOOLS_DIR})
    message(FATAL_ERROR "Environment variable CMAKE_LOCALIZE_TOOLS_DIR is not defined.")
endif()

# Make sure cmake will find find_modules.
set(TOOLCHAIN_CONFIG_DIR "$ENV{CMAKE_LOCALIZE_TOOLS_DIR}/toolchain/config")
include ("${TOOLCHAIN_CONFIG_DIR}/macosx-config.cmake")

set (CMAKE_FIND_ROOT_PATH "${SDKROOT}")
set (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set (CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set (CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

set( EXECUTABLE_OUTPUT_PATH "${PROJECT_BINARY_DIR}/bin" CACHE PATH "Output directory for applications" )
string (REPLACE ";" "_" CMAKE_OSX_ARCHITECTURES_STR "${CMAKE_OSX_ARCHITECTURES}")
set( LIBRARY_OUTPUT_PATH "${PROJECT_BINARY_DIR}/libs/${CMAKE_OSX_ARCHITECTURES_STR}"  CACHE PATH "Output directory for applications" )
