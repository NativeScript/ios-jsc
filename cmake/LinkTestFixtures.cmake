function(LinkTestFixtures _target)
    set(TESTFIXTURES_DIR "${CMAKE_SOURCE_DIR}/tests/TestFixtures")

    file(STRINGS "${TESTFIXTURES_DIR}/exported-symbols.txt" TESTFIXTURES_EXPORTED_SYMBOLS)

    target_include_directories(${_target} PUBLIC ${TESTFIXTURES_DIR})
    add_dependencies(${_target} TestFixtures)
    target_link_libraries(${_target} "-force_load $<TARGET_FILE:TestFixtures>")
    foreach(_symbol ${TESTFIXTURES_EXPORTED_SYMBOLS})
        set(LINK_FLAGS "${LINK_FLAGS} -Wl,-exported_symbol,_${_symbol}")
    endforeach()
    set_target_properties(${_target} PROPERTIES LINK_FLAGS ${LINK_FLAGS})
endfunction()
