# Cross compile TBB from source.
# Adapted from OpenCV's 3rdparty/tbb directory.
cmake_minimum_required(VERSION 2.8)
project(TBB)

set(VERSION_MAJOR 4)
set(VERSION_MINOR 2)
set(VERSION_PATCH 5)
set(PACKAGE_VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})

include_directories("include"
                    "src/"
                    "src/rml/include"
                    "cmake")  # For version string.

add_definitions(
  -std=c++11
  -D__TBB_DYNAMIC_LOAD_ENABLED=0   # Required.
  -D__TBB_BUILD=1                  # Required.
  -D__TBB_SURVIVE_THREAD_SWITCH=0  # No Cilk support.
  -DTBB_USE_DEBUG=0                # Just to be sure.
  -DTBB_NO_LEGACY=1                # Don't need backward compatibility.
  -DDO_ITT_NOTIFY=0                # Don't seem to need these notifications.
  -DUSE_PTHREAD                    # Required for Unix.
  -DTBB_USE_CAPTURED_EXCEPTION=0)  # Rethrow original exception, don't kill the stack trace.

# NOTE: Not building tbbmalloc or tbbproxy.
file(GLOB lib_srcs "src/tbb/*.cpp")
list(APPEND lib_srcs "src/rml/client/rml_tbb.cpp")
add_library(tbb ${lib_srcs})
target_link_libraries(tbb dl)

install(TARGETS tbb
        EXPORT ${PROJECT_NAME}Targets
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)

install(DIRECTORY include/tbb
        DESTINATION include)

# Figure out the relative path from the installed Config.cmake file to the
# install prefix. This relative path will be configured into <name>Config.cmake.
set(CMAKECONFIG_INSTALL_DIR lib/cmake/${PROJECT_NAME})
file(RELATIVE_PATH relInstallDir
     ${CMAKE_INSTALL_PREFIX}/${CMAKECONFIG_INSTALL_DIR} ${CMAKE_INSTALL_PREFIX})

# Export all targets put into the export set "<name>Targets".
install(EXPORT ${PROJECT_NAME}Targets
        DESTINATION ${CMAKECONFIG_INSTALL_DIR})

# Create <name>Config.cmake and <name>ConfigVersion.cmake files for find_package().
configure_file("cmake/${PROJECT_NAME}Config.cmake.in"
               "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake" @ONLY)
configure_file("cmake/${PROJECT_NAME}ConfigVersion.cmake.in"
               "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake" @ONLY)
install(FILES "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
              "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION ${CMAKECONFIG_INSTALL_DIR})
