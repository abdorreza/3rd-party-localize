
cmake_minimum_required (VERSION 2.8)
project(cxsparse C)

include_directories("${cxsparse_SOURCE_DIR}/Include")

file(GLOB TARGET_SRC "${cxsparse_SOURCE_DIR}/Source/*.c")
#add_definitions(-DNCOMPLEX)

add_library(${PROJECT_NAME} ${TARGET_SRC})