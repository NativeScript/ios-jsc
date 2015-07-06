set(RESOURCES app)

include(CreateNativeScriptApp)
CreateNativeScriptApp(TestRunner "${MAIN_TEMPLATE}" "${INFO_PLIST_TEMPLATE}" "${RESOURCES}")

include(LinkTestFixtures)
LinkTestFixtures(TestRunner)
