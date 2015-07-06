set(RESOURCES app)

include(CreateNativeScriptApp)
CreateNativeScriptApp(BlankApp main.m "${INFO_PLIST_TEMPLATE}" "${RESOURCES}")

include(LinkTestFixtures)
LinkTestFixtures(BlankApp)
