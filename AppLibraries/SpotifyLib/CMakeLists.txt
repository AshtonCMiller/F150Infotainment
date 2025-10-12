cmake_minimum_required(VERSION 3.16)

project(SpotifyLib LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core)

add_library(SpotifyLib SHARED
  SpotifyLib_global.h
  SpotifyLib.cpp
  SpotifyLib.h
  libinfo.json
)

target_link_libraries(SpotifyLib PRIVATE Qt${QT_VERSION_MAJOR}::Core)
target_link_libraries(SpotifyLib
  PUBLIC
  ControllerFactory
)

target_compile_definitions(SpotifyLib PRIVATE SPOTIFYLIB_LIBRARY)
