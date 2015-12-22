# - Try to find Pangolin
# Once done, this will define
#
#  Pangolin_FOUND - system has Pangolin
#  Pangolin_INCLUDE_DIRS - the Pangolin include directories
#  Pangolin_LIBRARIES - link these to use tbb

include(LibFindMacros)

# Find header and lib
find_path(Pangolin_INCLUDE_DIR NAMES pangolin/pangolin.h)
find_path(PangolinPlatform_INCLUDE_DIR NAMES pangolin/config.h)
find_library(Pangolin_LIBRARY NAMES pangolin)

# Dependencies
set(Pangolin_PROCESS_INCLUDES Pangolin_INCLUDE_DIR PangolinPlatform_INCLUDE_DIR)
set(Pangolin_PROCESS_LIBS Pangolin_LIBRARY)

# Process with libfind
libfind_process(Pangolin)
