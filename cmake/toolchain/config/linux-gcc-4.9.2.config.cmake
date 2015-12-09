# Make sure we let user know was is going wrong with includes.
if (NOT DEFINED TOOLCHAIN_CONFIG_DIR)
    message(FATAL_ERROR "TOOLCHAIN_CONFIG_DIR is not defiend")
endif()
include("${TOOLCHAIN_CONFIG_DIR}/c++-config.cmake")

if(ENABLE_SANITIZER)
    set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -fsanitize=undefined -fsanitize=address -fsanitize=leak")
endif()

# Work around for a bug Enable multithreading to use std::thread: Operation not permitted
# http://stackoverflow.com/questions/19463602/compiling-multithread-code-with-g
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -pthread -Wl,--no-as-needed")

if(ENABLE_STATIC_STD_LINK)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static"  CACHE STRING
        "Executable link flags")
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_INIT}" CACHE STRING
     "Flags used by the compiler during all build types.")
