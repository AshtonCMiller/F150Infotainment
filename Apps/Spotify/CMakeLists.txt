cmake_minimum_required(VERSION 3.16)

project(Spotify VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Core)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appSpotify
    main.cpp
)

qt_add_qml_module(appSpotify
    URI Spotify
    VERSION 1.0
    QML_FILES
        Main.qml
        RESOURCES SpotifyIcon.svg
        QML_FILES appinfo.json
        SOURCES
)

target_link_libraries(appSpotify
    PUBLIC
    ControllerFactory
    Qt6::Core
    Qt6::Quick
)
target_link_libraries(appSpotify PRIVATE Qt6::Core SpotifyLib)

include(GNUInstallDirs)
install(TARGETS appSpotify
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# add_library(appSpotify SHARED
#     SpotifyController.cpp
#     SpotifyController.h
# )
# target_link_libraries(appSpotify PRIVATE ControllerFactory Qt6::Core Qt6::Quick)
# set_target_properties(appSpotify PROPERTIES OUTPUT_NAME "SpotifyController")


# add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../ControllerFactory)
# target_link_libraries(appSpotify PUBLIC ControllerFactory::ControllerFactory)
