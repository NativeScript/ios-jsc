macro(GenerateMetadata _target)
    add_custom_command(TARGET ${_target}
        POST_BUILD
        COMMAND ./metadata-generation-build-step.sh
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/dist/metadataGenerator/bin"
    )
endmacro()
