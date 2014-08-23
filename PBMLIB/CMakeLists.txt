cmake_minimum_required (VERSION 2.6)
project (PBMLIB)

set(TARGET_SRC 
   PBMLIB.c
)

add_library(${PROJECT_NAME} ${TARGET_SRC})
