cmake_minimum_required(VERSION 3.16)

project(ThemeLib LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core)

add_library(ThemeLib SHARED
  ThemeManager.cpp
  ThemeManager.h
  Theme.qrc
)

# qt_add_qml_module(appInfotainmentSystem
#     URI ThemeLib
#     VERSION 1.0
#     SOURCES
#       ThemeManager.cpp
#       ThemeManager.h

#     RESOURCES
#       Theme.qrc
# )

target_link_libraries(ThemeLib PRIVATE Qt${QT_VERSION_MAJOR}::Core)

target_compile_definitions(ThemeLib PRIVATE THEMELIB_LIBRARY)
