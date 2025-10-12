cmake_minimum_required(VERSION 3.16)

project(ControllerFactory LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core)

add_library(ControllerFactory SHARED

  ControllerFactory.cpp
  ControllerFactory.h
)

target_link_libraries(ControllerFactory PUBLIC Qt${QT_VERSION_MAJOR}::Core) # Was PRIVATE
target_include_directories(ControllerFactory PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
# target_compile_definitions(ControllerFactory PUBLIC CONTROLLERFACTORY_LIBRARY) # Was PRIVATE
target_compile_definitions(ControllerFactory PRIVATE CONTROLLERFACTORY_LIBRARY)

# Make this build as a shared library
set_target_properties(ControllerFactory PROPERTIES
  EXPORT_NAME ControllerFactory
)
