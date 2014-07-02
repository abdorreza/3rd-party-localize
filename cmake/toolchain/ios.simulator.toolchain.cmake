# To cross compile for iOS simulator:
# build$ cmake .. -DCMAKE_TOOLCHAIN_FILE=../contrib/cmake/CrossCompile-iOS-Sim.cmake

SET(CMAKE_SYSTEM_NAME Generic)
if ("$ENV{IOS_SDK_VERSION}" STREQUAL "")
  SET(CMAKE_SYSTEM_VERSION 6.1)
else()
	SET(CMAKE_SYSTEM_VERSION $ENV{IOS_SDK_VERSION})
endif()
SET(CMAKE_SYSTEM_PROCESSOR i386)

SET(ARCHS "-arch i386")
SET(CMAKE_CROSSCOMPILING_TARGET IOS)
SET(CMAKE_OSX_ARCHITECTURES "i386")
SET(IOS ON)
SET(IOSSIM ON)
SET(UNIX ON)
SET(APPLE ON)
SET(LINUX OFF)

execute_process(COMMAND xcode-select -print-path
    OUTPUT_VARIABLE XCODE_SELECT OUTPUT_STRIP_TRAILING_WHITESPACE)

if(EXISTS ${XCODE_SELECT})
	SET(DEVROOT "${XCODE_SELECT}/Platforms/iPhoneSimulator.platform/Developer")
	if (NOT EXISTS "${DEVROOT}/SDKs/iPhoneSimulator${CMAKE_SYSTEM_VERSION}.sdk")
		# specified SDK version does not exist, use last one
		file(GLOB INSTALLED_SDKS ${DEVROOT}/SDKs/*)
		list(SORT INSTALLED_SDKS)
		list(REVERSE INSTALLED_SDKS)
		list(GET INSTALLED_SDKS 0 LATEST_SDK)
		string(REGEX MATCH "[0-9]\\.[0-9]" CMAKE_SYSTEM_VERSION ${LATEST_SDK})
	endif()
else()
	SET(DEVROOT "/Developer/Platforms/iPhoneSimulator.platform/Developer")
endif()

if (${CMAKE_SYSTEM_VERSION} VERSION_EQUAL "6.0" OR ${CMAKE_SYSTEM_VERSION} VERSION_GREATER "6.0")
  set(IOS6_OR_LATER ON)
else()
  set(IOS6_OR_LATER OFF)
endif()

if (IOS6_OR_LATER)
  # we have to use clang - llvm will choke on those __has_feature macros?
  SET (CMAKE_C_COMPILER "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang")
  SET (CMAKE_CXX_COMPILER "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++")

	if ($ENV{MACOSX_DEPLOYMENT_TARGET})
		message(FATAL_ERROR "llvm will croak with MACOSX_DEPLOYMENT_TARGET environment variable set when building for ios - unset MACOSX_DEPLOYMENT_TARGET")
	endif()

else()
  SET (CMAKE_C_COMPILER "${DEVROOT}/usr/bin/gcc")
  SET (CMAKE_CXX_COMPILER "${DEVROOT}/usr/bin/g++")
endif()

SET(SDKROOT "${DEVROOT}/SDKs/iPhoneSimulator${CMAKE_SYSTEM_VERSION}.sdk")
SET(CMAKE_OSX_SYSROOT "${SDKROOT}")


# force compiler and linker flags
SET(CMAKE_C_LINK_FLAGS ${ARCHS})
SET(CMAKE_CXX_LINK_FLAGS ${ARCHS})
# SET(CMAKE_C_FLAGS ${ARCHS}) # C_FLAGS wont stick, use ADD_DEFINITIONS instead
# SET(CMAKE_CXX_FLAGS ${ARCHS})
ADD_DEFINITIONS(${ARCHS})
ADD_DEFINITIONS("--sysroot=${SDKROOT}")

# ios headers
INCLUDE_DIRECTORIES(SYSTEM "${SDKROOT}/usr/include")

# ios libraries
LINK_DIRECTORIES("${SDKROOT}/usr/lib/system/host")
LINK_DIRECTORIES("${SDKROOT}/usr/lib/system")
LINK_DIRECTORIES("${SDKROOT}/usr/lib")


SET (CMAKE_FIND_ROOT_PATH "${SDKROOT}")
SET (CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
SET (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
SET (CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
