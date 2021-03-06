# To cross compile for Linux:
# build$ cmake .. -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/linux-gcc-4.9.2.toolchain.cmake

set (CMAKE_SYSTEM_NAME Linux)

set(CMAKE_CROSSCOMPILING_TARGET LINUX)
set(IOS OFF)
set(UNIX OFF)
set(APPLE OFF)
set(LINUX ON)
SET(ANDROID OFF)

set( GCC_INSTALL_ROOT "/usr" CACHE FILEPATH "Path to the root of clang install directory")
set( CMAKE_SYSTEM_NAME          "Linux" CACHE STRING "Target system." )
set( CMAKE_SYSTEM_PROCESSOR     "x86_64" CACHE STRING "Target processor." )
set( CMAKE_C_COMPILER           "${GCC_INSTALL_ROOT}/bin/gcc-4.9" )
set( CMAKE_CXX_COMPILER         "${GCC_INSTALL_ROOT}/bin/g++-4.9" )

#######################################################
# Config
#######################################################

if (NOT DEFINED ENV{CMAKE_LOCALIZE_TOOLS_DIR})
    message(FATAL_ERROR "Environment variable CMAKE_LOCALIZE_TOOLS_DIR is not defined.")
endif()

# Make sure cmake will find find_modules.
set(TOOLCHAIN_CONFIG_DIR "$ENV{CMAKE_LOCALIZE_TOOLS_DIR}/toolchain/config")
include ("${TOOLCHAIN_CONFIG_DIR}/linux-gcc-4.9.2.config.cmake")

set( EXECUTABLE_OUTPUT_PATH "${PROJECT_BINARY_DIR}/bin" CACHE PATH "Output directory for applications" )
string (REPLACE ";" "_" CMAKE_SYSTEM_PROCESSOR_STR "${CMAKE_SYSTEM_PROCESSOR}")
set( LIBRARY_OUTPUT_PATH "${PROJECT_BINARY_DIR}/libs/${CMAKE_SYSTEM_PROCESSOR_STR}"  CACHE PATH "Output directory for applications" )
