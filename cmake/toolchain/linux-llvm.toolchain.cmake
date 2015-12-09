# To cross compile for Linux:
# build$ cmake .. -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/linux-llvm.toolchain.cmake

set (CMAKE_SYSTEM_NAME Linux)

set(CMAKE_CROSSCOMPILING_TARGET LINUX)
set(IOS OFF)
set(UNIX OFF)
set(APPLE OFF)
set(LINUX ON)
SET(ANDROID OFF)

set( CLANG_INSTALL_ROOT "/usr" CACHE FILEPATH "Path to the root of clang install directory")
set( CMAKE_SYSTEM_NAME          "Linux" CACHE STRING "Target system." )
set( CMAKE_SYSTEM_PROCESSOR     "x86_64" CACHE STRING "Target processor." )
set( CMAKE_C_COMPILER           "${CLANG_INSTALL_ROOT}/bin/clang" )
set( CMAKE_CXX_COMPILER         "${CLANG_INSTALL_ROOT}/bin/clang++" )

#######################################################
# Config
#######################################################

if (NOT DEFINED ENV{CMAKE_LOCALIZE_TOOLS_DIR})
    message(FATAL_ERROR "Environment variable CMAKE_LOCALIZE_TOOLS_DIR is not defined.")
endif()

# Make sure cmake will find find_modules.
set(TOOLCHAIN_CONFIG_DIR "$ENV{CMAKE_LOCALIZE_TOOLS_DIR}/toolchain/config")
include ("${TOOLCHAIN_CONFIG_DIR}/linux-llvm-config.cmake")

set( EXECUTABLE_OUTPUT_PATH "${PROJECT_BINARY_DIR}/bin" CACHE PATH "Output directory for applications" )
string (REPLACE ";" "_" CMAKE_SYSTEM_PROCESSOR_STR "${CMAKE_SYSTEM_PROCESSOR}")
set( LIBRARY_OUTPUT_PATH "${PROJECT_BINARY_DIR}/libs/${CMAKE_SYSTEM_PROCESSOR_STR}"  CACHE PATH "Output directory for applications" )
