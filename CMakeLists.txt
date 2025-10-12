cmake_minimum_required(VERSION 3.16)

project(InfotainmentSystem VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Location)
find_package(Qt6 REQUIRED COMPONENTS Core)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appInfotainmentSystem
    main.cpp
)

target_compile_definitions(appInfotainmentSystem
    PRIVATE
    APP_VERSION="1.0.0"
)

qt_add_qml_module(appInfotainmentSystem
    URI InfotainmentSystem
    VERSION 1.0
    QML_FILES
        Main.qml
        QML_FILES
        SOURCES
        SOURCES
        SOURCES
        SOURCES
        RESOURCES customshaderbuildings.frag
        RESOURCES customshaderbuildings.vert
        RESOURCES customshadertiles.frag
        QML_FILES
        QML_FILES SmallMediaPlayer.qml
        SOURCES
        SOURCES
        SOURCES Controllers/system.h Controllers/system.cpp
        QML_FILES MapDisplay.qml
        SOURCES Controllers/navigation.h Controllers/navigation.cpp
        SOURCES Controllers/UpdateManager.h Controllers/UpdateManager.cpp
        SOURCES Controllers/AppManager.h Controllers/AppManager.cpp
        SOURCES
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appInfotainmentSystem PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appInfotainmentSystem
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appInfotainmentSystem
    PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Location
)
target_link_libraries(appInfotainmentSystem
    PUBLIC
    ControllerFactory
    ThemeLib
)
target_link_libraries(appInfotainmentSystem PRIVATE Qt6::Core)

include(GNUInstallDirs)
install(TARGETS appInfotainmentSystem
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
add_subdirectory(ThemeLib)
add_subdirectory(ControllerFactory) # Need this before all apps
add_subdirectory(AppLibraries/SpotifyLib) # We will do app libraries first
add_subdirectory(Apps/SettingsApp)
add_subdirectory(Apps/Spotify)
add_subdirectory(AppLibraries/SettingsLib)
