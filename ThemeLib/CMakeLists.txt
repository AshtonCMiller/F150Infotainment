cmake_minimum_required(VERSION 3.16)

project(ThemeLib LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Gui Qml Quick)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Gui Qml Quick)

add_library(ThemeLib SHARED
  ThemeManager.cpp
  ThemeManager.h
)
target_link_libraries(ThemeLib PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick)
# target_link_libraries(ThemeLib
#   PUBLIC
# )

target_compile_definitions(ThemeLib PRIVATE THEMELIB_LIBRARY)
