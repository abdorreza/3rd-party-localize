cmake_minimum_required (VERSION 2.8)
project (NavChipSDK)

set(TARGET_SRC 
	src/NavChip.cpp
	src/OS_Linux.cpp
)

include_directories("include")

add_library(${PROJECT_NAME} ${TARGET_SRC})
