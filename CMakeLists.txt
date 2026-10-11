cmake_minimum_required(VERSION 3.7)

project(orocos_kdl_vendor)

find_package(ament_cmake REQUIRED)

option(FORCE_BUILD_VENDOR_PKG
  "Build orocos_kdl from source, even if a system-installed package is available"
  OFF)

if(NOT FORCE_BUILD_VENDOR_PKG)
  find_package(orocos_kdl QUIET)
endif()

macro(build_orocos_kdl)
  set(extra_cmake_args)
  if(DEFINED CMAKE_BUILD_TYPE)
    list(APPEND extra_cmake_args -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
  endif()
  if(DEFINED BUILD_SHARED_LIBS)
    list(APPEND extra_cmake_args -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS})
  else()
    list(APPEND extra_cmake_args -DBUILD_SHARED_LIBS=ON)
  endif()
  if(DEFINED CMAKE_TOOLCHAIN_FILE)
    list(APPEND extra_cmake_args "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")
  endif()
  if(DEFINED CMAKE_CXX_STANDARD)
    list(APPEND extra_cmake_args "-DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}")
  endif()
  list(APPEND extra_cmake_args -DENABLE_TESTS:BOOL=OFF -DENABLE_EXAMPLES:BOOL=OFF)
  # VxWorks fix (jazzy orocos_kdl_vendor/usr_src/0001-add-eigen3-include.patch):
  # orocos_kdl's FindEigen3 can't locate eigen3 under cross-compile; point it at
  # the eigen already installed in the sysroot export prefix.
  list(APPEND extra_cmake_args "-DEIGEN3_INCLUDE_DIR=${CMAKE_INSTALL_PREFIX}/include/eigen3")

  include(ExternalProject)

  externalproject_add(orocos_kdl_external
    GIT_REPOSITORY https://github.com/orocos/orocos_kinematics_dynamics.git
    GIT_TAG v1.5.1
    GIT_CONFIG advice.detachedHead=false
    UPDATE_COMMAND ""
    TIMEOUT 600
    PATCH_COMMAND
      patch -p1 -N -r - < ${CMAKE_CURRENT_SOURCE_DIR}/patches/0001-orocos-kdl-interface-include.patch || true
    SOURCE_SUBDIR orocos_kdl
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_install
      ${extra_cmake_args}
  )

  install(
    DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_install/
    DESTINATION
      ${CMAKE_INSTALL_PREFIX}
    USE_SOURCE_PERMISSIONS
  )
endmacro()

if(NOT orocos_kdl_FOUND)
  message(STATUS "Did not find orocos_kdl installation, building from source")
  build_orocos_kdl()
endif()

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package(
  CONFIG_EXTRAS "orocos_kdl_vendor-extras.cmake"
)
