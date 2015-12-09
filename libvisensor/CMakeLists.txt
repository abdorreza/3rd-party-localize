cmake_minimum_required(VERSION 2.8.0)

############
# CATKIN STUFF
############
project(libvisensor)

set(CMAKE_LIBRARY_PATH
    ${CMAKE_LIBRARY_PATH}
    "${CMAKE_CURRENT_SOURCE_DIR}/../install/boost/lib/macosx")
set(CMAKE_INCLUDE_PATH
    ${CMAKE_INCLUDE_PATH}
    "${CMAKE_CURRENT_SOURCE_DIR}/../install/boost/include")
set(CMAKE_INCLUDE_PATH
    ${CMAKE_INCLUDE_PATH}
    "${CMAKE_CURRENT_SOURCE_DIR}/../eigen-3.2.5")

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
find_package(Boost REQUIRED)
find_package(Eigen REQUIRED)

message("Model path: ${CMAKE_LIBRARY_PATH}")
message("include:  ${Boost_INCLUDE_DIR}")
message("include:  ${EIGEN_INCLUDE_DIR}")


############
# SETTINGS
############
set(PKGNAME visensor)

###########
# BUILD
###########
FILE(
  GLOB SRCS 
  src/*.cpp 
  src/sensors/*.cpp
  src/networking/*.cpp
  src/synchronization/*.cpp
  src/serial_bridge/*.cpp
  src/visensor/*.cpp
  src/helpers/*.cpp
)
INCLUDE_DIRECTORIES("include")
include_directories(${EIGEN_INCLUDE_DIR} ${Boost_INCLUDE_DIR})

#Release / debug build

ADD_DEFINITIONS (-DVISENSOR_EXPORT -fPIC -fmessage-length=0 -MMD -MP -Wall -pedantic -std=c++11)
if(NOT DEFINED CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
    ADD_DEFINITIONS (-march=native -O3)
endif(NOT DEFINED CMAKE_BUILD_TYPE)

#static library
ADD_LIBRARY(${PKGNAME} STATIC ${SRCS})
#SET_TARGET_PROPERTIES(${PKGNAME}_static PROPERTIES OUTPUT_NAME ${PKGNAME})
TARGET_LINK_LIBRARIES(${PKGNAME} boost_thread boost_system) 
