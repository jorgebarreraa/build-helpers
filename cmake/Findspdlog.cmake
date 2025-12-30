# - Try to find spdlog include dirs and libraries
#
# Usage of this module as follows:
#
#     find_package(spdlog)
#
# Variables used by this module, they can change the default behaviour and need
# to be set before calling find_package:
#
#  spdlog_ROOT_DIR           Set this variable to the root installation of
#                            spdlog if the module has problems finding the
#                            proper installation path.
#
# Variables defined by this module:
#
#  spdlog_FOUND              System has spdlog, include and library dirs found
#  spdlog_INCLUDE_DIR        The spdlog include directories.
#  spdlog_LIBRARIES          The spdlog libraries.

include(tearoot-helper)
include(FindPackageHandleStandardArgs)

# First try to use spdlog's own config file if it exists
if(DEFINED spdlog_DIR)
    find_package(spdlog CONFIG QUIET HINTS ${spdlog_DIR})
endif()

if(NOT spdlog_FOUND)
    # Fallback to manual search
    message("spdlog root dir: ${spdlog_ROOT_DIR}")
    find_path(spdlog_INCLUDE_DIR
            NAMES spdlog/spdlog.h
            HINTS ${spdlog_ROOT_DIR}/ ${spdlog_ROOT_DIR}/include/
    )

    if (NOT TARGET spdlog::spdlog)
        find_library(spdlog_LIBRARIES
                NAMES spdlog libspdlog.a spdlog.a libspdlogd.a
                HINTS ${spdlog_ROOT_DIR} ${spdlog_ROOT_DIR}/${BUILD_OUTPUT} ${spdlog_ROOT_DIR}/lib
                )

        if (spdlog_LIBRARIES)
            add_library(spdlog::spdlog STATIC IMPORTED)
            set_target_properties(spdlog::spdlog PROPERTIES
                    IMPORTED_LOCATION ${spdlog_LIBRARIES}
                    INTERFACE_INCLUDE_DIRECTORIES ${spdlog_INCLUDE_DIR}
                    )
        endif ()
    endif ()

    find_package_handle_standard_args(spdlog DEFAULT_MSG
            spdlog_INCLUDE_DIR
            spdlog_LIBRARIES
    )

    mark_as_advanced(
            spdlog_ROOT_DIR
            spdlog_INCLUDE_DIR
            spdlog_LIBRARIES
    )
endif()
