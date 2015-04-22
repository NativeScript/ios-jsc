set(RESOURCES app)

include(CreateNativeScriptApp)
CreateNativeScriptApp(TestRunner "${MAIN_TEMPLATE}" "${INFO_PLIST_TEMPLATE}" "${RESOURCES}")

add_dependencies(TestRunner TestFixtures)
target_link_libraries(TestRunner "-force_load $<TARGET_FILE:TestFixtures>")
foreach(_symbol ${TESTFIXTURES_EXPORTED_SYMBOLS})
    set(LINK_FLAGS "${LINK_FLAGS} -Wl,-exported_symbol,_${_symbol}")
endforeach()

set_target_properties(TestRunner PROPERTIES LINK_FLAGS ${LINK_FLAGS})
