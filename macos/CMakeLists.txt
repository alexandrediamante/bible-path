cmake_minimum_required(VERSION 3.14)
project(Runner LANGUAGES C CXX OBJC OBJCXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Force the minimum macOS version for all targets
set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "Minimum macOS version" FORCE)

# Find Flutter
set(FLUTTER_ROOT "$ENV{FLUTTER_ROOT}" CACHE PATH "Flutter SDK root")
if(NOT FLUTTER_ROOT)
  message(FATAL_ERROR "FLUTTER_ROOT environment variable not set. Please set it to the Flutter SDK path.")
endif()

# Include Flutter CMake
include("${FLUTTER_ROOT}/packages/flutter_tools/cmake/flutter.cmake")

# Flutter setup
flutter_add_library(flutter)
flutter_add_plugin_libraries()

# Create the app bundle
add_executable(Runner MACOSX_BUNDLE
  Runner/MainFlutterWindow.swift
  Runner/AppDelegate.swift
  "${FLUTTER_ROOT}/packages/flutter_tools/cmake/FlutterMacOS.framework/Headers/FlutterMacOS.h"
)

target_link_libraries(Runner PRIVATE flutter)
target_link_libraries(Runner PRIVATE "${FLUTTER_ROOT}/packages/flutter_tools/cmake/FlutterMacOS.framework")

# Bundle settings
set_target_properties(Runner PROPERTIES
  MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Runner/Info.plist"
  MACOSX_BUNDLE_BUNDLE_NAME "Bible Path"
  MACOSX_BUNDLE_ICON_FILE "AppIcon"
  MACOSX_BUNDLE_GUI_IDENTIFIER "com.visionwizard.biblepath"
  MACOSX_BUNDLE_LONG_VERSION_STRING "1.0.0"
  MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0.0"
  MACOSX_BUNDLE_COPYRIGHT "Copyright © 2024 Bible Path. All rights reserved."
)

# Entitlements
if(CMAKE_BUILD_TYPE STREQUAL "Release")
  set_target_properties(Runner PROPERTIES
    MACOSX_BUNDLE_CODE_SIGN_ENTITLEMENTS "${CMAKE_CURRENT_SOURCE_DIR}/Runner/Release.entitlements"
  )
else()
  set_target_properties(Runner PROPERTIES
    MACOSX_BUNDLE_CODE_SIGN_ENTITLEMENTS "${CMAKE_CURRENT_SOURCE_DIR}/Runner/DebugProfile.entitlements"
  )
endif()

# Install
install(TARGETS Runner BUNDLE DESTINATION .)