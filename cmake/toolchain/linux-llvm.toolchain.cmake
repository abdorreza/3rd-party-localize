# To cross compile for Linux:
# build$ cmake .. -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/linux-llvm.toolchain.cmake

set(CMAKE_CROSSCOMPILING_TARGET LINUX)
set(IOS OFF)
set(UNIX OFF)
set(APPLE OFF)
set(LINUX ON)

set( CLANG_INSTALL_ROOT "/usr" CACHE FILEPATH "Path to the root of clang install directory")
set( CMAKE_SYSTEM_NAME          "Linux" CACHE STRING "Target system." )
set( CMAKE_SYSTEM_PROCESSOR     "x86_64" CACHE STRING "Target processor." )
set( CMAKE_C_COMPILER           "${CLANG_INSTALL_ROOT}/bin/clang" )
set( CMAKE_CXX_COMPILER         "${CLANG_INSTALL_ROOT}/bin/clang++" )
