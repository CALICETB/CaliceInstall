#########################################
#  Provides BUILD_FLAG. Usage:
#  BUILD_FLAG( <definition> <description> [ON|OFF] [<definitions list name>] [WARN])
#  <definition> : Name of preprocessor macro (definition) 
#                 to set
#  <description>: String to be displayed in menu
#  [ON|OFF]     : optional default value
#  <definitions list name>: name of list to switch definitions in 
#  [WARN]       : if WARN is given as last argument, issue a warning if current 
#                 value differs from default 
#
#  Provides cmake option "BUILD_WITH_<definition>". 
#  ${${PROJECT_NAME}_DEFINITIONS} will contain a list of 
#  definitnions (-D<definition>) according to the status 
#  of the options 
#
#  Example:
#  BUILD_FLAG( USE_LCCD     "build with support for LCCD" )
#  BUILD_FLAG( USE_MARLIN   "additional boundary check" ON )
#  BUILD_FLAG( USE_MARLIN   "additional boundary check" ON WARN)
#  BUILD_FLAG( EXTENDED_API "use extended API" ON ${PROJECT_NAME}_EXPORT_DEFINITIONS )
#  BUILD_FLAG( EXTENDED_API "use extended API" ON ${PROJECT_NAME}_EXPORT_DEFINITIONS WARN)


MACRO( BUILD_FLAG _bf_definition _bf_description )
  IF ( ${ARGC} GREATER 5 )
    MESSAGE( FATAL_ERROR "BUILD_FLAG invoked with incorrect arguments." )
  ENDIF ( ${ARGC} GREATER 5 )

  IF ( ${ARGC} GREATER 2 )
    SET( _bf_default ${ARGV2} )
  ELSE ( ${ARGC} GREATER 2 )
    SET( _bf_default OFF )
  ENDIF ( ${ARGC} GREATER 2 )

  IF ( ${ARGC} GREATER 3 )
    SET( _bf_deflist ${ARGV3} )
  ELSE ( ${ARGC} GREATER 3 )
    SET( _bf_deflist ${PROJECT_NAME}_DEFINITIONS )
  ENDIF ( ${ARGC} GREATER 3 )

  #check wheather last option is WARN
  IF ( ${ARGC} GREATER 2 )
    SET( _bf_argn ${ARGN} )
    LIST( REVERSE _bf_argn )
    LIST( GET _bf_argn 0 _bf_last )
   
    IF ( _bf_last MATCHES [Ww][Aa][Rr][Nn] )
       SET( _bf_warn TRUE )
    ELSE( _bf_last MATCHES [Ww][Aa][Rr][Nn] )
       SET( _bf_warn FALSE )
    ENDIF( _bf_last MATCHES [Ww][Aa][Rr][Nn] )
  ENDIF ( ${ARGC} GREATER 2 )


 

  OPTION( BUILD_WITH_${_bf_definition} "Compile with ${_bf_description}" ${_bf_default} )

  IF ( BUILD_WITH_${_bf_definition} )
      IF ( DEFINED ${_bf_deflist} )
         LIST( REMOVE_ITEM ${_bf_deflist} -D${_bf_definition} )
      ENDIF( DEFINED ${_bf_deflist} )
      LIST( APPEND      ${_bf_deflist} -D${_bf_definition} )
#     ADD_DEFINITIONS( -D${_bf_definition} )
  ELSE( BUILD_WITH_${_bf_definition} ) 
      IF ( DEFINED ${_bf_deflist} )
         LIST( REMOVE_ITEM ${_bf_deflist} -D${_bf_definition} )
      ENDIF( DEFINED ${_bf_deflist} )
#     REMOVE_DEFINITIONS( -D${_bf_definition} )
  ENDIF( BUILD_WITH_${_bf_definition} )

  IF( _bf_warn )
   #Fixme: do something smarter to allow TRUE == ON
   IF ( NOT ${BUILD_WITH_${_bf_definition}} STREQUAL ${_bf_default}  ) 
        MESSAGE( STATUS "WARNING: You changed option: BUILD_WITH_${_bf_definition} to ${BUILD_WITH_${_bf_definition}}. "
                        "Default is: ${_bf_default}. Proceed only if you know what you do!!!"                           )
   ENDIF( NOT ${BUILD_WITH_${_bf_definition}} STREQUAL ${_bf_default} ) 
  ENDIF( _bf_warn )



ENDMACRO( BUILD_FLAG )

