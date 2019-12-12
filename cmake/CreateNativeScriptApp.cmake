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
    )

    if(NOT ${BUILD_SHARED_LIBS})
        add_dependencies(${_target} NativeScript)
        target_link_libraries(${_target}
            libicucore.dylib
            libz.dylib
            libc++.dylib
            "-lNativeScript"
            "-L${NativeScriptFramework_BINARY_DIR}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)"
        )

        if(NOT ${EMBED_STATIC_DEPENDENCIES})
            target_link_libraries(${_target} ${WEBKIT_LIBRARIES} ffi)
        endif()
    else()
        add_dependencies(${_target} NativeScript)
        target_link_libraries(${_target}
            "-framework NativeScript"
            "-F${NativeScriptFramework_BINARY_DIR}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/"
        )
        set_target_properties(${_target} PROPERTIES
            XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS    "@executable_path/Frameworks"
        )

        # Copy the framework into the bundle and sign it
        add_custom_command(
            TARGET
            ${_target}
            POST_BUILD COMMAND 
            if [ "$$IS_UIKITFORMAC" = "YES" ]\; 
            then 
                DEST_PREFIX="Contents/MacOS"\; 
            else 
                DEST_PREFIX=""\; 
            fi && 
            DEST=${CMAKE_CURRENT_BINARY_DIR}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/${_target}.app/$$DEST_PREFIX/Frameworks &&
            rm -rf $$DEST && mkdir -p $$DEST &&
            cp -Rf ${NativeScriptFramework_BINARY_DIR}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/ $$DEST &&
            codesign --force --verbose $$DEST/NativeScript.framework --sign \"$(EXPANDED_CODE_SIGN_IDENTITY)\"
        )

    endif()

    set_target_properties(${_target} PROPERTIES
        MACOSX_BUNDLE YES
        MACOSX_BUNDLE_INFO_PLIST "${_plist}"
        RESOURCE "${_resources}"
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
        XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "YES"
        XCODE_ATTRIBUTE_GCC_C_LANGUAGE_STANDARD "gnu99"
        XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT[variant=Debug] "DWARF"
        XCODE_ATTRIBUTE_INSTALL_PATH "$DSTROOT"
        XCODE_ATTRIBUTE_SKIP_INSTALL "No"
        XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "$ENV{DEVELOPMENT_TEAM}"
        XCODE_ATTRIBUTE_PROVISIONING_PROFILE_SPECIFIER "$ENV{PROVISIONING}"
    )

    if(DEFINED ENV{NATIVESCRIPT_APPLE_DEVELOPMENT_TEAM_ID})
        set_target_properties(${_target} PROPERTIES
            XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "$ENV{NATIVESCRIPT_APPLE_DEVELOPMENT_TEAM_ID}"
        )
    endif()

    include(SetActiveArchitectures)
    SetActiveArchitectures(${_target})

    include(GenerateMetadata)
    GenerateMetadata(${_target})
endfunction()
