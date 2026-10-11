find_package(orocos_kdl QUIET)

# orocos_kdl's exported `orocos-kdl` imported target carries IMPORTED_LOCATION
# but NOT INTERFACE_INCLUDE_DIRECTORIES (the include dirs live only in the
# orocos_kdl_INCLUDE_DIRS variable). Modern consumers (kdl_parser, tf2_kdl)
# target_link_libraries(orocos-kdl) and rely on the target to propagate the
# include path -> "kdl/tree.hpp not found". Attach it here.
if(TARGET orocos-kdl AND DEFINED orocos_kdl_INCLUDE_DIRS)
  set_property(TARGET orocos-kdl APPEND PROPERTY
    INTERFACE_INCLUDE_DIRECTORIES "${orocos_kdl_INCLUDE_DIRS}")
endif()
