set(RESOURCES app)

include(CreateNativeScriptApp)
CreateNativeScriptApp(HelloWorldApp "${MAIN_TEMPLATE}" "${INFO_PLIST_TEMPLATE}" "${RESOURCES}")
