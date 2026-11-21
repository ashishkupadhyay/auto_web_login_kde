cmake_minimum_required(VERSION 3.16)

project(vitportallogin VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(ECM 6.0.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Network DBus Qml Quick)

qt_add_library(vitportalplugin SHARED
    src/vitportal_plugin.cpp
    src/vitportalcontroller.cpp
    src/ssidwatcher.cpp
)

target_include_directories(vitportalplugin PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)

target_link_libraries(vitportalplugin PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Network
    Qt6::DBus
    Qt6::Qml
    Qt6::Quick
)

set_target_properties(vitportalplugin PROPERTIES
    OUTPUT_NAME "vitportalplugin"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml/org/kde/plasma/private/vitportal"
)

file(WRITE "${CMAKE_BINARY_DIR}/qml/org/kde/plasma/private/vitportal/qmldir"
"module org.kde.plasma.private.vitportal\nplugin vitportalplugin\n")

install(TARGETS vitportalplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/vitportal)
install(FILES "${CMAKE_BINARY_DIR}/qml/org/kde/plasma/private/vitportal/qmldir"
    DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/vitportal)

install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/package/"
    DESTINATION "${KDE_INSTALL_DATAROOTDIR}/plasma/plasmoids/org.kde.plasma.vitportallogin")

message(STATUS "Install QML plugin to: ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/vitportal")
message(STATUS "If the widget fails to load the import, ensure that directory is on Qt's QML import path (e.g. same prefix as Qt, or set QML2_IMPORT_PATH).")
