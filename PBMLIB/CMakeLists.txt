cmake_minimum_required (VERSION 2.8)
project (pbmpak)

set(TARGET_SRC 
   pbmpak.c
)

add_library(${PROJECT_NAME} ${TARGET_SRC})
