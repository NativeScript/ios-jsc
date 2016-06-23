function(CreateNativeScriptApp _target _main _plist _resources)
    include_directories("${RUNTIME_DIR}/**" ${NATIVESCRIPT_DEBUGGING_DIR})
    link_directories(${WEBKIT_LINK_DIRECTORIES} "${LIBFFI_LIB_DIR}")

    add_executable(${_target} ${_main} ${_resources})

    target_link_libraries(${_target}
        "-ObjC"
        "-framework CoreGraphics"
        "-framework UIKit"
        "-framework MobileCoreServices"
        "-framework Security"
        NativeScript
    )

    set_target_properties(${_target} PROPERTIES
        MACOSX_BUNDLE YES
        MACOSX_BUNDLE_INFO_PLIST "${_plist}"
        RESOURCE "${_resources}"
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
        XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "YES"
        XCODE_ATTRIBUTE_GCC_C_LANGUAGE_STANDARD "gnu99"
        XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT[variant=Debug] "DWARF"
    )

    include(SetActiveArchitectures)
    SetActiveArchitectures(${_target})

    include(GenerateMetadata)
    GenerateMetadata(${_target})
endfunction()
