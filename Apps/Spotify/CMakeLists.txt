# cmake_minimum_required(VERSION 3.16)

# project(SpotifyPlugin LANGUAGES CXX)

# # Build the Spotify app as a shared library
# add_library(SpotifyPlugin SHARED
#     Controllers/SpotifyController.cpp
#     Controllers/SpotifyController.h
#     Main.qml
#     appinfo.json
# )



# # Set C++ standard
# target_compile_features(SpotifyPlugin PUBLIC cxx_std_17)

# # Find necessary Qt modules
# find_package(Qt6 REQUIRED COMPONENTS Core Quick Qml)

# # Link libraries: Qt and ControllerFactory
# target_link_libraries(SpotifyPlugin
#     PRIVATE
#         Qt6::Core
#         Qt6::Quick
#         Qt6::Qml
#         ControllerFactory
# )

# # Include current directory for headers
# target_include_directories(SpotifyPlugin
#     PRIVATE
#         ${CMAKE_CURRENT_SOURCE_DIR}
# )

# # Set output properties
# # The shared library file will be named "SpotifyController.so" (or .dll / .dylib)
# set_target_properties(SpotifyPlugin PROPERTIES
#     OUTPUT_NAME "SpotifyController"        # file name for dynamic loader
#     PREFIX ""                               # removes "lib" prefix on Unix
#     LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/plugins"
#     RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/plugins"
#     ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/plugins"
# )

# # Windows: export all symbols automatically
# if (WIN32)
#     set_target_properties(SpotifyPlugin PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
# endif()

# Optional: Add QML and resource files if Spotify app has them
# qt6_add_resources(SPOTIFY_QRC
#     PREFIX "/Apps/Spotify"
#     QML_FILES
#         Main.qml
#         #RESOURCES SpotifyIcon.svg
#         QML_FILES appinfo.json
#         SOURCES Controllers/SpotifyController.h Controllers/SpotifyController.cpp
# )

# set(SPOTIFY_RESOURCES
#     Main.qml
#     SpotifyIcon.svg
#     appinfo.json
# )

# target_sources(SpotifyPlugin
#     PRIVATE
#     ${SPOTIFY_RESOURCES}
# )

# set_target_properties(SpotifyPlugin PROPERTIES
#     OUTPUT_NAME "SpotifyController"
#     PREFIX ""
#     LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/plugins"
#     RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/plugins"
#     ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/plugins"
# )



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
