function(EmbedResourceInHeader _target _fileName)
    get_filename_component(FILENAME_WITHOUT_EXTENSION ${_fileName} NAME_WE)
    set(RESOURCE_FILE ${_fileName})
    set(HEADER_FILE ${CMAKE_CURRENT_BINARY_DIR}/${FILENAME_WITHOUT_EXTENSION}.h)

    add_custom_command(TARGET ${_target}
        PRE_BUILD
        COMMAND if \[\[ ${RESOURCE_FILE} -nt ${HEADER_FILE} ]] \; then echo "Generating ${HEADER_FILE}" && xxd -i ${RESOURCE_FILE} > ${HEADER_FILE} \; fi
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endfunction()
