# Copyright 2016 MongoDB Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Find libmongo-c, either via pkg-config, find-package in config mode,
# or other less admirable jiggery-pokery

if ( LIBMONGOC_FOUND )
  return()
endif()

if (DEFINED ENV{LIBMONGOC_DIR})
  SET(LIBMONGOC_DIR "$ENV{LIBMONGOC_DIR}" CACHE STRING "Manual search path for libmongoc")
else()
  SET(LIBMONGOC_DIR "" CACHE STRING "Manual search path for libmongoc")
endif()

include(FindPackageHandleStandardArgs)

# Load up PkgConfig if we have it
find_package(PkgConfig QUIET)

if(LIBMONGOC_DIR)
  # Trust the user's override path by default
  set(LIBMONGOC_LIBRARIES mongoc-1.0 CACHE INTERNAL "")
  set(LIBMONGOC_LIBRARY_DIRS ${LIBMONGOC_DIR}/lib CACHE INTERNAL "")
  set(LIBMONGOC_INCLUDE_DIRS ${LIBMONGOC_DIR}/include/libmongoc-1.0 CACHE INTERNAL "")
  find_package_handle_standard_args(LIBMONGOC DEFAULT_MSG LIBMONGOC_LIBRARIES LIBMONGOC_LIBRARY_DIRS LIBMONGOC_INCLUDE_DIRS)
elseif (PKG_CONFIG_FOUND)
  # The best we can do until libMONGOC starts installing a libmongoc-config.cmake file
  pkg_check_modules(LIBMONGOC libmongoc-1.0>=${LibMongoC_FIND_VERSION} )
  # We don't reiterate the version information here because we assume that
  # pkg_check_modules has honored our request.
  find_package_handle_standard_args(LIBMONGOC DEFAULT_MSG LIBMONGOC_FOUND)
else()
    message(FATAL_ERROR "Don't know how to find libmongoc; please set LIBMONGOC_DIR to the prefix directory with which libbson was configured.")
endif()

if ( LIBMONGOC_FOUND )
  set(LIBMONGOC_LIBRARIES_FULLPATH)
  foreach( mylib ${LIBMONGOC_LIBRARIES} )
    find_library (CURRENT_LIBMONGOC ${mylib} HINTS ${LIBMONGOC_LIBRARY_DIRS} )
    if (CURRENT_LIBMONGOC)
      list(APPEND LIBMONGOC_LIBRARIES_FULLPATH ${CURRENT_LIBMONGOC})
      unset(CURRENT_LIBMONGOC CACHE)
    endif()
  endforeach()
  set(LIBMONGOC_LIBRARIES ${LIBMONGOC_LIBRARIES_FULLPATH} CACHE INTERNAL "")

  if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin" AND LIBMONGOC_LDFLAGS_OTHER)
      # pkg_check_modules strips framework libraries and puts them in the
      # LIBMONGOC_LDFLAGS_OTHER variable.  We need to append them
      # back to LIBMONGOC_LIBRARIES, but need to change from
      # "-framework;Security;-framework;CoreFoundation" to
      # "-framework Security;-framework CoreFoundation"
      string(REPLACE "-framework;" "-framework " LIBMONGOC_FRAMEWORKS "${LIBMONGOC_LDFLAGS_OTHER}")
      list(APPEND LIBMONGOC_LIBRARIES ${LIBMONGOC_FRAMEWORKS})
      # publish updated value back to the cache
      set(LIBMONGOC_LIBRARIES ${LIBMONGOC_LIBRARIES} CACHE INTERNAL "")
  endif()
endif()
