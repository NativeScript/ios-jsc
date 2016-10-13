set(HEADER_FILES
    Calling/FFICall.h
    Calling/FFICallback.h
    Calling/FFICallbackInlines.h
    Calling/FFICallPrototype.h
    Calling/FFIFunctionCall.h
    Calling/FFIFunctionCallback.h
    GlobalObject.h
    inspector/CachedResource.h
    inspector/DomainBackendDispatcher.h
    inspector/DomainInspectorAgent.h
    inspector/GlobalObjectConsoleClient.h
    inspector/GlobalObjectDebuggerAgent.h
    inspector/GlobalObjectInspectorController.h
    inspector/InspectorNetworkAgent.h
    inspector/InspectorPageAgent.h
    inspector/InspectorTimelineAgent.h
    inspector/MimeTypeHelper.h
    inspector/SuppressAllPauses.h
    Interop.h
    JSErrors.h
    JSWarnings.h
    LiveEdit/ClearChangedCellsFunctor.h
    LiveEdit/EditableSourceProvider.h
    LiveEdit/TextualDifferencesHelper.h
    Marshalling/FFISimpleType.h
    Marshalling/FFIType.h
    Marshalling/FunctionReference/FunctionReferenceConstructor.h
    Marshalling/FunctionReference/FunctionReferenceInstance.h
    Marshalling/FunctionReference/FunctionReferenceTypeConstructor.h
    Marshalling/FunctionReference/FunctionReferenceTypeInstance.h
    Marshalling/Fundamentals/FFINumericTypes.h
    Marshalling/Fundamentals/FFIPrimitiveTypes.h
    Marshalling/Pointer/PointerConstructor.h
    Marshalling/Pointer/PointerInstance.h
    Marshalling/Pointer/PointerPrototype.h
    Marshalling/Record/RecordConstructor.h
    Marshalling/Record/RecordField.h
    Marshalling/Record/RecordInstance.h
    Marshalling/Record/RecordPrototype.h
    Marshalling/Record/RecordPrototypeFunctions.h
    Marshalling/Record/RecordType.h
    Marshalling/Reference/ReferenceConstructor.h
    Marshalling/Reference/ReferenceInstance.h
    Marshalling/Reference/ReferencePrototype.h
    Marshalling/Reference/ReferenceTypeConstructor.h
    Marshalling/Reference/ReferenceTypeInstance.h
    Metadata/Metadata.h
    NativeScript-Prefix.h
    NativeScript.h
    ObjC/AllocatedPlaceholder.h
    ObjC/Block/ObjCBlockCall.h
    ObjC/Block/ObjCBlockCallback.h
    ObjC/Block/ObjCBlockType.h
    ObjC/Block/ObjCBlockTypeConstructor.h
    ObjC/Constructor/ObjCConstructorBase.h
    ObjC/Constructor/ObjCConstructorCall.h
    ObjC/Constructor/ObjCConstructorDerived.h
    ObjC/Constructor/ObjCConstructorNative.h
    ObjC/Enumeration/ObjCFastEnumerationIterator.h
    ObjC/Enumeration/ObjCFastEnumerationIteratorPrototype.h
    ObjC/Enumeration/TNSFastEnumerationAdapter.h
    ObjC/Inheritance/ObjCClassBuilder.h
    ObjC/Inheritance/ObjCExtend.h
    ObjC/Inheritance/ObjCTypeScriptExtend.h
    ObjC/NSErrorWrapperConstructor.h
    ObjC/ObjCMethodCall.h
    ObjC/ObjCMethodCallback.h
    ObjC/ObjCPrimitiveTypes.h
    ObjC/ObjCProtocolWrapper.h
    ObjC/ObjCPrototype.h
    ObjC/ObjCSuperObject.h
    ObjC/ObjCTypes.h
    ObjC/ObjCWrapperObject.h
    ObjC/TNSArrayAdapter.h
    ObjC/TNSDataAdapter.h
    ObjC/TNSDictionaryAdapter.h
    ObjC/TNSExceptionHandler.h
    ObjC/Unmanaged/UnmanagedInstance.h
    ObjC/Unmanaged/UnmanagedPrototype.h
    ObjC/Unmanaged/UnmanagedType.h
    Runtime/JSWeakRefConstructor.h
    Runtime/JSWeakRefInstance.h
    Runtime/JSWeakRefPrototype.h
    Runtime/ReleasePool.h
    SymbolLoader.h
    TimelineRecordFactory.h
    TNSRuntime+Diagnostics.h
    TNSRuntime+Inspector.h
    TNSRuntime+Private.h
    TNSRuntime.h
    TypeFactory.h
    WeakHandleOwners.h
    Workers/JSWorkerConstructor.h
    Workers/JSWorkerGlobalObject.h
    Workers/JSWorkerInstance.h
    Workers/JSWorkerPrototype.h
    Workers/WorkerMessagingProxy.h
)

set(SOURCE_FILES
    Calling/FFICall.cpp
    Calling/FFICallPrototype.cpp
    Calling/FFIFunctionCall.mm
    Calling/FFIFunctionCallback.cpp
    GlobalObject.mm
    GlobalObject.moduleLoader.mm
    inspector/CachedResource.mm
    inspector/DomainBackendDispatcher.cpp
    inspector/DomainInspectorAgent.cpp
    inspector/GlobalObjectConsoleClient.cpp
    inspector/GlobalObjectDebuggerAgent.mm
    inspector/GlobalObjectInspectorController.cpp
    inspector/InspectorNetworkAgent.cpp
    inspector/InspectorPageAgent.mm
    inspector/InspectorTimelineAgent.cpp
    inspector/SuppressAllPauses.cpp
    Interop.mm
    JSErrors.mm
    JSWarnings.cpp
    LiveEdit/ClearChangedCellsFunctor.cpp
    LiveEdit/TextualDifferencesHelper.cpp
    Marshalling/FFISimpleType.cpp
    Marshalling/FFIType.cpp
    Marshalling/FunctionReference/FunctionReferenceConstructor.cpp
    Marshalling/FunctionReference/FunctionReferenceInstance.cpp
    Marshalling/FunctionReference/FunctionReferenceTypeConstructor.cpp
    Marshalling/FunctionReference/FunctionReferenceTypeInstance.cpp
    Marshalling/Fundamentals/FFINumericTypes.mm
    Marshalling/Fundamentals/FFIPrimitiveTypes.cpp
    Marshalling/Pointer/PointerConstructor.cpp
    Marshalling/Pointer/PointerInstance.cpp
    Marshalling/Pointer/PointerPrototype.cpp
    Marshalling/Record/RecordConstructor.cpp
    Marshalling/Record/RecordField.cpp
    Marshalling/Record/RecordInstance.cpp
    Marshalling/Record/RecordPrototype.cpp
    Marshalling/Record/RecordPrototypeFunctions.cpp
    Marshalling/Reference/ReferenceConstructor.cpp
    Marshalling/Reference/ReferenceInstance.cpp
    Marshalling/Reference/ReferencePrototype.cpp
    Marshalling/Reference/ReferenceTypeConstructor.cpp
    Marshalling/Reference/ReferenceTypeInstance.cpp
    Metadata/Metadata.mm
    ObjC/AllocatedPlaceholder.cpp
    ObjC/Block/ObjCBlockCall.mm
    ObjC/Block/ObjCBlockCallback.cpp
    ObjC/Block/ObjCBlockType.mm
    ObjC/Block/ObjCBlockTypeConstructor.cpp
    ObjC/Constructor/ObjCConstructorBase.mm
    ObjC/Constructor/ObjCConstructorCall.mm
    ObjC/Constructor/ObjCConstructorDerived.cpp
    ObjC/Constructor/ObjCConstructorNative.mm
    ObjC/Enumeration/ObjCFastEnumerationIterator.mm
    ObjC/Enumeration/ObjCFastEnumerationIteratorPrototype.mm
    ObjC/Enumeration/TNSFastEnumerationAdapter.mm
    ObjC/Inheritance/ObjCClassBuilder.mm
    ObjC/Inheritance/ObjCExtend.mm
    ObjC/Inheritance/ObjCTypeScriptExtend.mm
    ObjC/NSErrorWrapperConstructor.mm
    ObjC/ObjCMethodCall.mm
    ObjC/ObjCMethodCallback.mm
    ObjC/ObjCPrimitiveTypes.mm
    ObjC/ObjCProtocolWrapper.mm
    ObjC/ObjCPrototype.mm
    ObjC/ObjCSuperObject.mm
    ObjC/ObjCTypes.mm
    ObjC/ObjCWrapperObject.mm
    ObjC/TNSArrayAdapter.mm
    ObjC/TNSDataAdapter.mm
    ObjC/TNSDictionaryAdapter.mm
    ObjC/Unmanaged/UnmanagedInstance.cpp
    ObjC/Unmanaged/UnmanagedPrototype.mm
    ObjC/Unmanaged/UnmanagedType.cpp
    Runtime/JSWeakRefConstructor.cpp
    Runtime/JSWeakRefInstance.cpp
    Runtime/JSWeakRefPrototype.cpp
    SymbolLoader.mm
    TimelineRecordFactory.cpp
    TNSRuntime+Diagnostics.mm
    TNSRuntime+Inspector.mm
    TNSRuntime.mm
    TypeFactory.mm
    Workers/JSWorkerConstructor.cpp
    Workers/JSWorkerGlobalObject.mm
    Workers/JSWorkerInstance.mm
    Workers/JSWorkerPrototype.cpp
    Workers/WorkerMessagingProxy.mm
)

set(NativeScript_PUBLIC_HEADERS
    NativeScript.h
    TNSRuntime+Diagnostics.h
    TNSRuntime+Inspector.h
    TNSRuntime.h
)

set(JSFILES
    __extends.js
    inlineFunctions.js
)

include_directories("${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/**" "${LIBFFI_INCLUDE_DIR}" "${WEBKIT_INCLUDE_DIRECTORIES}")
link_directories("${LIBFFI_LIB_DIR}" ${WEBKIT_LINK_DIRECTORIES})

add_library(NativeScript ${SOURCE_FILES} ${HEADER_FILES} ${JSFILES})

add_dependencies(NativeScript WebKit libffi)

set_target_properties(NativeScript PROPERTIES
    COMPILE_FLAGS "
        -fno-exceptions -fno-rtti -fno-objc-arc
        -Werror -Wall -Wextra -Wcast-align -Wformat-security -Wmissing-format-attribute -Wpointer-arith -Wundef -Wwrite-strings
        -Wno-shorten-64-to-32 -Wno-bool-conversion -Wno-unused-parameter -Wno-macro-redefined
    "
)

target_compile_definitions(NativeScript PUBLIC "NATIVESCRIPT_VERSION=${NATIVESCRIPT_VERSION}")

if(${BUILD_SHARED_LIBS})
    set_target_properties(NativeScript PROPERTIES
        FRAMEWORK TRUE
        # FRAMEWORK_VERSION "1.0" # TODO
        INSTALL_NAME_DIR "@executable_path/Frameworks"
        MACOSX_FRAMEWORK_BUNDLE_VERSION "${BASE_NATIVESCRIPT_VERSION}"
        MACOSX_FRAMEWORK_IDENTIFIER "org.nativescript.NativeScript"
        MACOSX_FRAMEWORK_SHORT_VERSION_STRING "${BASE_NATIVESCRIPT_VERSION}"
        PUBLIC_HEADER "${NativeScript_PUBLIC_HEADERS}"
        XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT[variant=Debug] "DWARF"
    )
    target_link_libraries(NativeScript
        ${WEBKIT_LIBRARIES}
        ffi
        libicucore.dylib
        libz.dylib
        libc++.dylib
        "-framework UIKit"
        "-framework MobileCoreServices"
        "-framework Security"
        "-Wl,-exported_symbol,_JSContextGetGlobalObject"
        "-Wl,-exported_symbol,_JSStringCopyCFString"
        "-Wl,-exported_symbol,_JSObjectCallAsFunction"
        "-Wl,-exported_symbol,_JSObjectGetProperty"
        "-Wl,-exported_symbol,_JSObjectMakeError"
        "-Wl,-exported_symbol,_JSObjectSetProperty"
        "-Wl,-exported_symbol,_JSStringCreateWithUTF8CString"
        "-Wl,-exported_symbol,_JSStringRelease"
        "-Wl,-exported_symbol,_JSValueIsUndefined"
        "-Wl,-exported_symbol,_JSValueMakeString"
        "-Wl,-exported_symbol,_JSValueToStringCopy"
        "-Wl,-exported_symbol,_JSValueToObject"
        "-Wl,-exported_symbol,_JSValueToNumber"
        "-Wl,-exported_symbol,_OBJC_CLASS_$_TNSRuntime"
        "-Wl,-exported_symbol,_OBJC_CLASS_$_TNSRuntimeInspector"
        "-Wl,-exported_symbol,_TNSInspectorRunLoopMode"
        "-Wl,-exported_symbol,_TNSSetUncaughtErrorHandler"
    )
elseif(${EMBED_STATIC_DEPENDENCIES})
    foreach(_directory ${WEBKIT_LINK_DIRECTORIES})
        set(NativeScript_LIBTOOL_FLAGS "${NativeScript_LIBTOOL_FLAGS} -L${_directory}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)")
    endforeach()
    foreach(_library ${WEBKIT_LIBRARIES})
        set(NativeScript_LIBTOOL_FLAGS "${NativeScript_LIBTOOL_FLAGS} -l${_library}")
    endforeach()

    set_target_properties(NativeScript PROPERTIES
        STATIC_LIBRARY_FLAGS "${NativeScript_LIBTOOL_FLAGS} -L${LIBFFI_LIB_DIR} -lffi"
    )
endif()

include(EmbedResourceInHeader)
foreach(_jsfile ${JSFILES})
    EmbedResourceInHeader(NativeScript ${_jsfile})
endforeach()

include(SetActiveArchitectures)
SetActiveArchitectures(NativeScript)

include(GroupSources)
GroupSources(NativeScript)

include(PrecompiledHeaders)
SetPrecompiledHeader(NativeScript NativeScript-Prefix.h)
