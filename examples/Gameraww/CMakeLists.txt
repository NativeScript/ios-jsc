set(RESOURCES
    app
    GAMApplication.storyboard
    Images.xcassets
)

file(COPY ${INFO_PLIST_TEMPLATE} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
execute_process(COMMAND plutil -insert UIMainStoryboardFile -string GAMApplication ${CMAKE_CURRENT_BINARY_DIR}/Info.plist)

include(CreateNativeScriptApp)
CreateNativeScriptApp(Gameraww "${MAIN_TEMPLATE}" "${CMAKE_CURRENT_BINARY_DIR}/Info.plist" "${RESOURCES}")
