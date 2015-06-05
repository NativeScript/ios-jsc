function(CreateNativeScriptApp _target _main _plist _resources)
    include_directories(${RUNTIME_DIR} ${NATIVESCRIPT_DEBUGGING_DIR})
    link_directories(${WEBKIT_LINK_DIRECTORIES} "${LIBFFI_DIR}/lib")

    add_executable(${_target} ${_main} ${_resources})
    add_dependencies(${_target} MetadataGenerator)

    target_link_libraries(${_target}
        "-framework CoreGraphics"
        "-framework UIKit"
        NativeScript
    )

    if(NOT ${BUILD_SHARED_LIBS})
        target_link_libraries(${_target}
            libicucore.dylib
            libz.dylib
            libc++.dylib
        )
        
        if(NOT ${EMBED_STATIC_DEPENDENCIES})
            target_link_libraries(${_target} ${WEBKIT_LIBRARIES} ffi)
        endif()
    endif()

    set_target_properties(${_target} PROPERTIES
        MACOSX_BUNDLE YES
        MACOSX_BUNDLE_INFO_PLIST "${_plist}"
        RESOURCE "${_resources}"
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
        XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "7.0"
        COMPILE_FLAGS "-fobjc-arc"
        XCODE_ATTRIBUTE_GCC_C_LANGUAGE_STANDARD "gnu99"
        XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT[variant=Debug] "DWARF"
    )

    include(SetActiveArchitectures)
    SetActiveArchitectures(${_target})

    include(GenerateMetadata)
    GenerateMetadata(${_target})
endfunction()
