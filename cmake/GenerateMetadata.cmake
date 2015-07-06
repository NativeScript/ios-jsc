macro(GenerateMetadata _target)
    add_dependencies(${_target} MetadataGenerator)
    add_custom_command(TARGET ${_target}
        POST_BUILD
        COMMAND "${CMAKE_SOURCE_DIR}/build/scripts/metadata-generation-build-step.sh"
        WORKING_DIRECTORY "${MetadataGenerator_BINARY_DIR}/bin"
    )
endmacro()
