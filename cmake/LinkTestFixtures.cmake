function(LinkTestFixtures _target)
    set(TESTFIXTURES_DIR "${CMAKE_SOURCE_DIR}/tests/TestFixtures")

    target_include_directories(${_target} PUBLIC ${TESTFIXTURES_DIR})
    add_dependencies(${_target} TestFixtures)
    target_link_libraries(${_target} "-force_load $<TARGET_FILE:TestFixtures>")
    
    # Tell linker to keep all symbols listed in exported-symbols.txt
    set_target_properties(${_target} PROPERTIES XCODE_ATTRIBUTE_EXPORTED_SYMBOLS_FILE "${TESTFIXTURES_DIR}/exported-symbols.txt")
    # EXPORTED_SYMBOLS_FILE is passed to linker only we need to prevent them from being stripped by the strip tool as well
    set_target_properties(${_target} PROPERTIES XCODE_ATTRIBUTE_STRIPFLAGS "-s ${TESTFIXTURES_DIR}/exported-symbols.txt")

endfunction()
