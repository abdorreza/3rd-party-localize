# Make sure we let user know was is going wrong with includes.
if (NOT DEFINED TOOLCHAIN_CONFIG_DIR)
    message(FATAL_ERROR "TOOLCHAIN_CONFIG_DIR is not defiend")
endif()
include("${TOOLCHAIN_CONFIG_DIR}/c++-config.cmake")
include("${TOOLCHAIN_CONFIG_DIR}/apple-config.cmake")

##
## For -Wunreachable-code-aggressive read:
##    http://llvm.org/klaus/clang/commit/5f5ef97906ab54fd9f60f8b30894af4af9394b5e/
##    http://www.dwheeler.com/essays/apple-goto-fail.html#gcc-unreachable
##
## For -Wimplicit-fallthrough, clang supports this warning but gcc does not, read:
##    http://stackoverflow.com/q/27965722/1708801
##    http://clang-developers.42468.n3.nabble.com/should-Wimplicit-fallthrough-require-C-11-td4028144.html
##
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -Wunreachable-code-aggressive")
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -Wimplicit-fallthrough")
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -DTARGET_OS_MAC_OSX=1")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_INIT}" CACHE STRING
     "Flags used by the compiler during all build types.")
