# - Try to find yaml-cpp include dirs and libraries
#
# Usage of this module as follows:
#
#     find_package(yaml-cpp)
#
# Variables used by this module, they can change the default behaviour and need
# to be set before calling find_package:
#
#  yaml-cpp_ROOT_DIR         Set this variable to the root installation of
#                            yaml-cpp if the module has problems finding the
#                            proper installation path.
#
# Variables defined by this module:
#
#  yaml-cpp_FOUND            System has yaml-cpp, include and library dirs found
#  yaml-cpp_INCLUDE_DIR      The yaml-cpp include directories.
#  yaml-cpp_LIBRARIES        The yaml-cpp libraries.

include(tearoot-helper)
include(FindPackageHandleStandardArgs)

# First try to use yaml-cpp's own config file if it exists
set(yaml-cpp_DIR "${yaml-cpp_ROOT_DIR}/lib/cmake/yaml-cpp" CACHE PATH "Path to yaml-cpp cmake config")
find_package(yaml-cpp CONFIG QUIET HINTS ${yaml-cpp_DIR})

if(NOT yaml-cpp_FOUND)
    # Fallback to manual search
    message("yaml-cpp root dir: ${yaml-cpp_ROOT_DIR}")
    find_path(yaml-cpp_INCLUDE_DIR
            NAMES yaml-cpp/yaml.h
            HINTS ${yaml-cpp_ROOT_DIR}/ ${yaml-cpp_ROOT_DIR}/include/
    )

    if (NOT TARGET yaml-cpp)
        find_library(yaml-cpp_LIBRARIES
                NAMES yaml-cpp libyaml-cpp.a yaml-cpp.a libyaml-cppd.a
                HINTS ${yaml-cpp_ROOT_DIR} ${yaml-cpp_ROOT_DIR}/${BUILD_OUTPUT} ${yaml-cpp_ROOT_DIR}/lib
                )

        if (yaml-cpp_LIBRARIES)
            add_library(yaml-cpp STATIC IMPORTED)
            set_target_properties(yaml-cpp PROPERTIES
                    IMPORTED_LOCATION ${yaml-cpp_LIBRARIES}
                    INTERFACE_INCLUDE_DIRECTORIES ${yaml-cpp_INCLUDE_DIR}
                    )
        endif ()
    endif ()

    find_package_handle_standard_args(yaml-cpp DEFAULT_MSG
            yaml-cpp_INCLUDE_DIR
            yaml-cpp_LIBRARIES
    )

    mark_as_advanced(
            yaml-cpp_ROOT_DIR
            yaml-cpp_INCLUDE_DIR
            yaml-cpp_LIBRARIES
    )
endif()
