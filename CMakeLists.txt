########################################################
# cmake file for building
# @author Eldwan Brianne
CMAKE_MINIMUM_REQUIRED(VERSION 2.6 FATAL_ERROR)
########################################################

# project name
PROJECT( CaliceInstall )

### PACKAGE VERSIONS ########################################################
SET( ${PROJECT_NAME}_VERSION_MAJOR 1 )
SET( ${PROJECT_NAME}_VERSION_MINOR 0 )
SET( ${PROJECT_NAME}_VERSION_PATCH 0 )

#################################################################
# Require C++11                                                 #
#################################################################

OPTION( ENABLE_C++11 "Set to OFF to skip build with c++11" ON )
MESSAGE( STATUS "ENABLE_C++11: ${ENABLE_C++11}" )

INCLUDE( CheckCXXCompilerFlag )

IF(ENABLE_C++11)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)

IF( COMPILER_SUPPORTS_CXX11 )
SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
ELSE()
MESSAGE( SEND_ERROR "Requires C++11 support. Please upgrade your compiler !" )
ENDIF()
ENDIF()

###############################
# versions of CALICE subpackages
# don't forget to update when releasing
# e.g. SET( CALICE_USERLIB_version "v01-00-00" )

SET( CALICE_USERLIB_version        "master" )
SET( CALICE_RECO_version           "master" )
SET( ROOTTREEWRITER_version        "master" )
SET( LABVIEW_CONVERTER_version     "master" )
SET( CALICE_ANALYSIS_version       "master" )
SET( CALICE_CALIB_version          "master" )
SET( CALICE_SIM_version            "master" )
SET( CALICE_ROOTMACROS_version     "master" )
SET( CALICE_STEERING_version       "master" )
SET( CALICE_DD_TB_version          "master" )
SET( FLCHCALSOFT_version           "master" )
SET( CALICE_CDDATA_version         "master" )
SET( CALICE_STANDALONEG4_version   "master" )
SET( CALICE_DB_TOOLS_version       "master" )

# ----- download settings -----
SET( CALICE_USERLIB_repository      "https://stash.desy.de/scm/calice/calice_userlib.git" )
SET( CALICE_RECO_repository         "https://stash.desy.de/scm/calice/calice_reco.git" )
SET( ROOTTREEWRITER_repository      "https://stash.desy.de/scm/calice/RootTreeWriter.git" )
SET( LABVIEW_CONVERTER_repository   "https://stash.desy.de/scm/calice/labview_converter.git" )
SET( CALICE_ANALYSIS_repository     "https://stash.desy.de/scm/calice/calice_analysis.git" )
SET( CALICE_CALIB_repository        "https://stash.desy.de/scm/calice/calice_calib.git" )
SET( CALICE_SIM_repository          "https://stash.desy.de/scm/calice/calice_sim.git" )
SET( CALICE_ROOTMACROS_repository   "https://stash.desy.de/scm/calice/calice_ROOTmacros.git" )
SET( CALICE_STEERING_repository     "https://stash.desy.de/scm/calice/calice_steering.git" )
SET( CALICE_DD_TB_repository        "https://stash.desy.de/scm/calice/calice_dd_testbeams.git" )
SET( FLCHCALSOFT_repository         "https://stash.desy.de/scm/calice/flchcalsoftware.git" )
SET( CALICE_CDDATA_repository       "https://stash.desy.de/scm/calice/calice_cddata.git" )
SET( CALICE_STANDALONEG4_repository "https://stash.desy.de/scm/calice/calice_standaloneg4.git" )
SET( CALICE_DB_TOOLS_repository     "https://stash.desy.de/scm/calice/calice_db_tools.git" )

# ----- dependencies -----
FIND_PACKAGE( ILCUTIL COMPONENTS ILCSOFT_CMAKE_MODULES QUIET )

LIST( APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake )
INCLUDE( default_settings )

# ----------------------------------------------------------------------------

INCLUDE( ExternalProject )

# In order to pass semicolon-separated lists over the command line to all packages,
# we need to separate list elements with '%' instead of the standard cmake list separator ';'
# The list separator needs also to be redefined in the ExternalProject_Add calls by setting
# the variable LIST_SEPARATOR

FOREACH( _path ${CMAKE_PREFIX_PATH} )
    SET( CMAKE_PREFIX_PATH_FIXED ${CMAKE_PREFIX_PATH_FIXED}%${_path} )
ENDFOREACH()

FOREACH( _path ${CMAKE_MODULE_PATH} )
    SET( CMAKE_MODULE_PATH_FIXED ${CMAKE_MODULE_PATH_FIXED}%${_path} )
ENDFOREACH()

# ----- cmake arguments common to ALL cmake packages -------------------------
SET( common_cmake_args
     "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH_FIXED}"
     "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH_FIXED}"
     "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
)

INCLUDE( DetectDistribution )

# ----- package options -----------------------------------------------------------------------

OPTION( BUILD_CALICE_SIM "Set to OFF to skip build/install calice sim package" ON )
MESSAGE( STATUS "BUILD_CALICE_SIM: ${BUILD_CALICE_SIM}" )

OPTION( BUILD_CALICE_CALIB "Set to OFF to skip build/install calice calib package" ON )
MESSAGE( STATUS "BUILD_CALICE_CALIB: ${BUILD_CALICE_CALIB}" )

# ----------------------------------------------------------------------------

# ----- calice userlib package -----
ExternalProject_Add( CALICE_USERLIB
    GIT_REPOSITORY ${CALICE_USERLIB_repository}
    GIT_TAG ${CALICE_USERLIB_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CMAKE_ARGS ${common_cmake_args}
    PREFIX calice_userlib-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_userlib
    LIST_SEPARATOR %
)

# ----- labview converter package -----
ExternalProject_Add( LABVIEW_CONVERTER
	DEPENDS CALICE_USERLIB
    GIT_REPOSITORY ${LABVIEW_CONVERTER_repository}
    GIT_TAG ${LABVIEW_CONVERTER_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CMAKE_ARGS ${common_cmake_args}
    PREFIX labview_converter-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/labview_converter
    LIST_SEPARATOR %
)

# ----- calice reco package -----
ExternalProject_Add( CALICE_RECO
	DEPENDS CALICE_USERLIB LABVIEW_CONVERTER
    GIT_REPOSITORY ${CALICE_RECO_repository}
    GIT_TAG ${CALICE_RECO_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CMAKE_ARGS ${common_cmake_args}
    PREFIX calice_reco-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_reco
    LIST_SEPARATOR %
)

# ----- RootTreeWriter package -----
ExternalProject_Add( ROOTTREEWRITER
	DEPENDS CALICE_USERLIB CALICE_RECO LABVIEW_CONVERTER
    GIT_REPOSITORY ${ROOTTREEWRITER_repository}
    GIT_TAG ${ROOTTREEWRITER_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CMAKE_ARGS ${common_cmake_args}
    PREFIX RootTreeWriter-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/RootTreeWriter
    LIST_SEPARATOR %
)

# ----- RootTreeWriter package -----
ExternalProject_Add( CALICE_DB_TOOLS
	DEPENDS CALICE_USERLIB CALICE_RECO LABVIEW_CONVERTER
    GIT_REPOSITORY ${CALICE_DB_TOOLS_repository}
    GIT_TAG ${CALICE_DB_TOOLS_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CMAKE_ARGS ${common_cmake_args}
    PREFIX calice_db_tools-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_db_tools
    LIST_SEPARATOR %
)

# ----- calice analysis package -----

IF( NOT BOOST_ROOT )
SET( BOOST_ROOT $ENV{BOOST_ROOT} )
IF( NOT BOOST_ROOT )
MESSAGE( FATAL_ERROR "BOOST_ROOT was not found in the environment. Please precise BOOST_ROOT with -DBOOST_ROOT=\"\" or set it by export BOOST_ROOT=\"\"" )
ENDIF()
ENDIF()

MESSAGE( STATUS "Boost root is ${BOOST_ROOT}" )

ExternalProject_Add( CALICE_ANALYSIS
	DEPENDS CALICE_USERLIB CALICE_RECO LABVIEW_CONVERTER
    GIT_REPOSITORY ${CALICE_ANALYSIS_repository}
    GIT_TAG ${CALICE_ANALYSIS_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CMAKE_ARGS ${common_cmake_args}
    PREFIX calice_analysis-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_analysis
    LIST_SEPARATOR %
)

IF( BUILD_CALICE_CALIB )

# ----- calice calib package -----
ExternalProject_Add( CALICE_CALIB
	DEPENDS CALICE_USERLIB CALICE_RECO LABVIEW_CONVERTER
    GIT_REPOSITORY ${CALICE_CALIB_repository}
    GIT_TAG ${CALICE_CALIB_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CMAKE_ARGS ${common_cmake_args}
    PREFIX calice_calib-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_calib
    LIST_SEPARATOR %
)

ENDIF()

IF( BUILD_CALICE_SIM )

# ----- calice sim package -----
ExternalProject_Add( CALICE_SIM
	DEPENDS CALICE_USERLIB CALICE_RECO LABVIEW_CONVERTER
    GIT_REPOSITORY ${CALICE_SIM_repository}
    GIT_TAG ${CALICE_SIM_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CMAKE_ARGS ${common_cmake_args}
    PREFIX calice_sim-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_sim
    LIST_SEPARATOR %
)

ENDIF()

# ----- calice ROOT macros package -----
ExternalProject_Add( CALICE_ROOTMACROS
    GIT_REPOSITORY ${CALICE_ROOTMACROS_repository}
    GIT_TAG ${CALICE_ROOTMACROS_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    PREFIX calice_ROOTmacros-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_ROOTmacros
    LIST_SEPARATOR %
)

# ----- calice steering macros package -----
ExternalProject_Add( CALICE_STEERING
    GIT_REPOSITORY ${CALICE_STEERING_repository}
    GIT_TAG ${CALICE_STEERING_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    PREFIX calice_steering-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_steering
    LIST_SEPARATOR %
)

# ----- calice dd testbeams macros package -----
ExternalProject_Add( CALICE_DD_TB
    GIT_REPOSITORY ${CALICE_DD_TB_repository}
    GIT_TAG ${CALICE_DD_TB_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    PREFIX calice_dd_testbeams-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_dd_testbeams
    LIST_SEPARATOR %
)

# ----- calice cddata package -----
ExternalProject_Add( CALICE_CDDATA
	DEPENDS CALICE_USERLIB CALICE_RECO LABVIEW_CONVERTER
    GIT_REPOSITORY ${CALICE_CDDATA_repository}
    GIT_TAG ${CALICE_CDDATA_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CMAKE_ARGS ${common_cmake_args}
    PREFIX calice_cddata-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_cddata
    LIST_SEPARATOR %
)

# ----- flchcalsoftware package -----
ExternalProject_Add( FLCHCALSOFT
    GIT_REPOSITORY ${FLCHCALSOFT_repository}
    GIT_TAG ${FLCHCALSOFT_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    PREFIX flchcalsoftware-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/flchcalsoftware
    LIST_SEPARATOR %
)

# ----- g4standalone package -----
ExternalProject_Add( CALICE_STANDALONEG4
    GIT_REPOSITORY ${CALICE_STANDALONEG4_repository}
    GIT_TAG ${CALICE_STANDALONEG4_version}
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    PREFIX calice_standaloneg4-prefix
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_standaloneg4
    LIST_SEPARATOR %
)


MESSAGE( STATUS "Calice software will be installed in ${CMAKE_INSTALL_PREFIX}" )

# display some variables and write them to cache
DISPLAY_STD_VARIABLES()
