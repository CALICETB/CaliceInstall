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

INCLUDE( CheckCXXCompilerFlag )

CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)

IF( COMPILER_SUPPORTS_CXX11 )
SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
ELSE()
MESSAGE( SEND_ERROR "Requires C++11 support. Please upgrade your compiler !" )
ENDIF()

###############################
# versions of CALICE subpackages
# don't forget to update when releasing 
# e.g. SET( CALICE_USERLIB_version "v01-00-00" )

SET( CALICE_USERLIB_version        "-rHEAD" )
SET( CALICE_RECO_version           "-rHEAD" )
SET( ROOTTREEWRITER_version        "-rHEAD" )
SET( LABVIEW_CONVERTER_version     "-rHEAD" )
SET( CALICE_ANALYSIS_version       "-rHEAD" )
SET( CALICE_CALIB_version          "-rHEAD" )
SET( CALICE_SIM_version            "-rHEAD" )

# ----- download settings -----
SET( CALICE_USERLIB_repository      "https://svnsrv.desy.de/public/calice/calice_userlib/trunk" )
SET( CALICE_RECO_repository         "https://svnsrv.desy.de/public/calice/calice_reco/trunk" )
SET( ROOTTREEWRITER_repository      "https://svnsrv.desy.de/public/calice/calice_tools/RootTreeWriter/trunk" )
SET( LABVIEW_CONVERTER_repository   "https://svnsrv.desy.de/public/calice/calice_tools/labview-converter/trunk" )
SET( CALICE_ANALYSIS_repository     "https://svnsrv.desy.de/public/calice/calice_analysis/trunk" )
SET( CALICE_CALIB_repository        "https://svnsrv.desy.de/public/calice/calice_calib/trunk" )
SET( CALICE_SIM_repository          "https://svnsrv.desy.de/public/calice/calice_sim/trunk" )

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

OPTION( BUILD_CALICE_SIM "Set to OFF to skip build/install calice sim package" OFF )
MESSAGE( STATUS "BUILD_CALICE_SIM: ${BUILD_CALICE_SIM}" )

OPTION( BUILD_CALICE_CALIB "Set to OFF to skip build/install calice calib package" OFF )
MESSAGE( STATUS "BUILD_CALICE_CALIB: ${BUILD_CALICE_CALIB}" )

# ----------------------------------------------------------------------------

IF( ${LINUX_DISTRO} MATCHES "Ubuntu" )

# ----- calice userlib package -----
ExternalProject_Add( CALICE_USERLIB
    SVN_REPOSITORY ${CALICE_USERLIB_repository}
    SVN_REVISION ${CALICE_USERLIB_version}
    PATCH_COMMAND patch ${CMAKE_CURRENT_SOURCE_DIR}/calice_userlib/include/DBInitString.hh < ${PROJECT_SOURCE_DIR}/patch/DBInitString.patch
    CMAKE_ARGS ${common_cmake_args} -DDB_INIT_STRING="flccaldb02.desy.de:calice:caliceon:Delice.1:3306"
    PREFIX calice_userlib
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_userlib
    LIST_SEPARATOR %
)

ELSE()

ExternalProject_Add( CALICE_USERLIB
    SVN_REPOSITORY ${CALICE_USERLIB_repository}
    SVN_REVISION ${CALICE_USERLIB_version}
    PATCH_COMMAND ""
    CMAKE_ARGS ${common_cmake_args} -DDB_INIT_STRING="flccaldb02.desy.de:calice:caliceon:Delice.1:3306"
    PREFIX calice_userlib
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_userlib
    LIST_SEPARATOR %
)

ENDIF()

# ----- labview converter package -----
ExternalProject_Add( LABVIEW_CONVERTER
    SVN_REPOSITORY ${LABVIEW_CONVERTER_repository}
    SVN_REVISION ${LABVIEW_CONVERTER_version}
    CMAKE_ARGS ${common_cmake_args}
    PREFIX labview_converter
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/labview_converter
    LIST_SEPARATOR %
)

# ----- calice reco package -----
ExternalProject_Add( CALICE_RECO
	DEPENDS CALICE_USERLIB LABVIEW_CONVERTER
    SVN_REPOSITORY ${CALICE_RECO_repository}
    SVN_REVISION ${CALICE_RECO_version}
    CMAKE_ARGS ${common_cmake_args}
    PREFIX calice_reco
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_reco
    LIST_SEPARATOR %
)

# ----- RootTreeWriter package -----
ExternalProject_Add( ROOTTREEWRITER
	DEPENDS CALICE_USERLIB CALICE_RECO LABVIEW_CONVERTER
    SVN_REPOSITORY ${ROOTTREEWRITER_repository}
    SVN_REVISION ${ROOTTREEWRITER_version}
    CMAKE_ARGS ${common_cmake_args}
    PREFIX RootTreeWriter
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/RootTreeWriter
    LIST_SEPARATOR %
)

# ----- calice analysis package -----

IF( NOT BOOST_ROOT )
SET( BOOST_ROOT $ENV{BOOST_ROOT} )
IF( NOT BOOST_ROOT )
MESSAGE( FATAL_ERROR "BOOST_ROOT was not found in the environment. Please precise BOOST_ROOT with -DBOOST_ROOT="" or set it by export BOOST_ROOT=""" )
ENDIF()
ENDIF()

MESSAGE( STATUS "Boost root is ${BOOST_ROOT}" )

ExternalProject_Add( CALICE_ANALYSIS
	DEPENDS CALICE_USERLIB CALICE_RECO LABVIEW_CONVERTER
    SVN_REPOSITORY ${CALICE_ANALYSIS_repository}
    SVN_REVISION ${CALICE_ANALYSIS_version}
    PATCH_COMMAND cp ${PROJECT_SOURCE_DIR}/patch/FindBOOST.patch /tmp/FindBOOST_temp.patch && sed -i "s#BOOST_ROOT#${BOOST_ROOT}#g" /tmp/FindBOOST_temp.patch && patch ${CMAKE_CURRENT_SOURCE_DIR}/calice_analysis/addonProcs/cmake/FindBOOST.cmake < /tmp/FindBOOST_temp.patch && rm /tmp/FindBOOST_temp.patch
    CMAKE_ARGS ${common_cmake_args}
    PREFIX calice_analysis
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_analysis
    LIST_SEPARATOR %
)

IF( BUILD_CALICE_CALIB )

# ----- calice calib package -----
ExternalProject_Add( CALICE_CALIB
	DEPENDS CALICE_USERLIB CALICE_RECO LABVIEW_CONVERTER
    SVN_REPOSITORY ${CALICE_CALIB_repository}
    SVN_REVISION ${CALICE_CALIB_version}
    CMAKE_ARGS ${common_cmake_args}
    PREFIX calice_calib
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_calib
    LIST_SEPARATOR %
)

ENDIF()

IF( BUILD_CALICE_SIM )

# ----- calice sim package -----
ExternalProject_Add( CALICE_SIM
	DEPENDS CALICE_USERLIB CALICE_RECO LABVIEW_CONVERTER
    SVN_REPOSITORY ${CALICE_SIM_repository}
    SVN_REVISION ${CALICE_SIM_version}
    CMAKE_ARGS ${common_cmake_args}
    PREFIX calice_sim
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/calice_sim
    LIST_SEPARATOR %
)

ENDIF()

MESSAGE( STATUS "Calice software will be installed in ${CMAKE_INSTALL_PREFIX}" )

# display some variables and write them to cache
DISPLAY_STD_VARIABLES()
