# Make sure we let user know was is going wrong with includes.
if (NOT DEFINED TOOLCHAIN_CONFIG_DIR)
    message(FATAL_ERROR "TOOLCHAIN_CONFIG_DIR is not defiend")
endif()

include("${TOOLCHAIN_CONFIG_DIR}/c++-config.cmake")
include("${TOOLCHAIN_CONFIG_DIR}/apple-config.cmake")

# Hidden visibility is required for cxx on iOS 
set (IOS_CONFIG_CMAKE_FLAGS "${IOS_CONFIG_CMAKE_FLAGS} -fvisibility=hidden -fvisibility-inlines-hidden -isysroot ${CMAKE_OSX_SYSROOT}")
set (IOS_CONFIG_CMAKE_FLAGS "${IOS_CONFIG_CMAKE_FLAGS} -Wno-shorten-64-to-32")
set (IOS_CONFIG_CMAKE_FLAGS "${IOS_CONFIG_CMAKE_FLAGS} ${CMAKE_SYSTEM_FRAMEWORK_PATH_STRING}")

set (APPLE_LINK_FLAGS "${APPLE_LINK_FLAGS} ${CMAKE_SYSTEM_FRAMEWORK_PATH_STRING}")

if (${IOS_PLATFORM} STREQUAL "OS")
        set (IOS_CONFIG_CMAKE_FLAGS "${IOS_CONFIG_CMAKE_FLAGS} -DTARGET_OS_IPHONE=1")
        # -DENABLE_NEON_OPTIMIZATION
        # iOS does not requare these flags to be enable
        # It is enables by default
		set (IOS_CONFIG_CMAKE_FLAGS "${IOS_CONFIG_CMAKE_FLAGS} -DENABLE_NEON_OPTIMIZATION")
else (${IOS_PLATFORM} STREQUAL "OS")
	# SIMULATOR
        set (IOS_CONFIG_CMAKE_FLAGS "${IOS_CONFIG_CMAKE_FLAGS} -DTARGET_IPHONE_SIMULATOR=1")
endif (${IOS_PLATFORM} STREQUAL "OS")

# Set C flags
set (CMAKE_C_FLAGS_INIT "${CMAKE_C_FLAGS_INIT} ${IOS_CONFIG_CMAKE_FLAGS}")
set (CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} ${IOS_CONFIG_CMAKE_FLAGS}")
set (CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -DGTEST_HAS_PTHREAD=0")

SET (CMAKE_C_FLAGS_DEBUG_INIT          "-g")
SET (CMAKE_C_FLAGS_MINSIZEREL_INIT     "-Os -DNDEBUG")
SET (CMAKE_C_FLAGS_RELEASE_INIT        "-O3 -DNDEBUG")
SET (CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "-O2 -g")

SET (CMAKE_CXX_FLAGS_DEBUG_INIT          "-g")
SET (CMAKE_CXX_FLAGS_MINSIZEREL_INIT     "-Os -DNDEBUG")
SET (CMAKE_CXX_FLAGS_RELEASE_INIT        "-O3 -DNDEBUG")
SET (CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-O2 -g")