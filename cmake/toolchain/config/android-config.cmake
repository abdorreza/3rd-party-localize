# Make sure we let user know was is going wrong with includes.
if (NOT DEFINED TOOLCHAIN_CONFIG_DIR)
    message(FATAL_ERROR "TOOLCHAIN_CONFIG_DIR is not defiend")
endif()
include("${TOOLCHAIN_CONFIG_DIR}/c++-config.cmake")

set (CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -mfpu=neon -mfloat-abi=softfp -DENABLE_NEON_OPTIMIZATION")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_INIT}")

#SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_INIT}" CACHE STRING
#     "Flags used by the compiler during all build types.")
