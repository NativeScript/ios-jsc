function(CreateNativeScriptApp _target _main _plist _resources)
    include_directories(${RUNTIME_DIR} ${TESTFIXTURES_DIR} ${NATIVESCRIPT_DEBUGGING_DIR})
    link_directories(${LIBFFI_DIR}/lib ${WEBKIT_DIR}/lib ${POCKET_SOCKET_DIR}/lib)

    add_executable(${_target} ${_main} ${_resources})
    add_dependencies(${_target} MetadataGenerator)

    target_link_libraries(${_target}
        "-framework CoreGraphics"
        "-framework UIKit"
        NativeScript
        libicucore.dylib
        libz.dylib
        libc++.dylib
    )

    target_link_libraries(${_target} debug "-ObjC" TNSDebugging)

    set_target_properties(${_target} PROPERTIES
        MACOSX_BUNDLE YES
        MACOSX_BUNDLE_INFO_PLIST "${_plist}"
        RESOURCE "${_resources}"
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
    )

    set_target_properties(${_target} PROPERTIES XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "7.0")

    include(SetActiveArchitectures)
    SetActiveArchitectures(${_target})

    include(GenerateMetadata)
    GenerateMetadata(${_target})
endfunction()
