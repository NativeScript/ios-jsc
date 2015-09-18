macro(GenerateMetadata _target)
    add_dependencies(${_target} MetadataGenerator)
    add_custom_command(TARGET ${_target}
        PRE_BUILD
        COMMAND "${CMAKE_SOURCE_DIR}/build/scripts/metadata-generation-build-step"
        WORKING_DIRECTORY "${MetadataGenerator_BINARY_DIR}/bin"
    )
    target_link_libraries(${_target}
    	"-sectcreate __DATA __TNSMetadata $(CONFIGURATION_BUILD_DIR)/metadata-$(CURRENT_ARCH).bin"
    )
endmacro()
