set(HEADER_FILES
    NativeScript-Prefix.h

    Calling/FFICall.h
    Calling/FFICallback.h
    Calling/FFICallbackInlines.h
    Calling/FFIFunctionCall.h
    Calling/FFIFunctionCallback.h
    GlobalObject.h
    Interop.h
    JSErrors.h
    JSWarnings.h
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
    Metadata/MetaFile.h
    Metadata/MetaFileReader.h
    NativeScript.h
    ObjC/Block/ObjCBlockCall.h
    ObjC/Block/ObjCBlockCallback.h
    ObjC/Block/ObjCBlockType.h
    ObjC/Block/ObjCBlockTypeConstructor.h
    ObjC/Constructor/ObjCConstructorBase.h
    ObjC/Constructor/ObjCConstructorCall.h
    ObjC/Constructor/ObjCConstructorDerived.h
    ObjC/Constructor/ObjCConstructorNative.h
    ObjC/Inheritance/ObjCClassBuilder.h
    ObjC/Inheritance/ObjCExtend.h
    ObjC/Inheritance/ObjCTypeScriptExtend.h
    ObjC/ObjCMethodCall.h
    ObjC/ObjCMethodCallback.h
    ObjC/ObjCPrimitiveTypes.h
    ObjC/ObjCProtocolWrapper.h
    ObjC/ObjCPrototype.h
    ObjC/ObjCSuperObject.h
    ObjC/ObjCTypes.h
    ObjC/ObjCWrapperObject.h
    ObjC/TNSArrayAdapter.h
    ObjC/TNSDictionaryAdapter.h
    Runtime/JSWeakRefConstructor.h
    Runtime/JSWeakRefInstance.h
    Runtime/JSWeakRefPrototype.h
    SymbolLoader.h
    TNSRuntime+Diagnostics.h
    TNSRuntime+Inspector.h
    TNSRuntime+Private.h
    TNSRuntime.h
    TypeFactory.h
    WeakHandleOwners.h
)

set(SOURCE_FILES
    Calling/FFICall.cpp
    Calling/FFIFunctionCall.mm
    Calling/FFIFunctionCallback.cpp
    GlobalObject.mm
    Interop.mm
    JSErrors.mm
    JSWarnings.cpp
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
    Metadata/MetaFile.mm
    Metadata/MetaFileReader.cpp
    ObjC/Block/ObjCBlockCall.mm
    ObjC/Block/ObjCBlockCallback.cpp
    ObjC/Block/ObjCBlockType.mm
    ObjC/Block/ObjCBlockTypeConstructor.cpp
    ObjC/Constructor/ObjCConstructorBase.mm
    ObjC/Constructor/ObjCConstructorCall.mm
    ObjC/Constructor/ObjCConstructorDerived.cpp
    ObjC/Constructor/ObjCConstructorNative.mm
    ObjC/Inheritance/ObjCClassBuilder.mm
    ObjC/Inheritance/ObjCExtend.mm
    ObjC/Inheritance/ObjCTypeScriptExtend.mm
    ObjC/ObjCMethodCall.mm
    ObjC/ObjCMethodCallback.mm
    ObjC/ObjCPrimitiveTypes.mm
    ObjC/ObjCProtocolWrapper.mm
    ObjC/ObjCPrototype.mm
    ObjC/ObjCSuperObject.mm
    ObjC/ObjCTypes.mm
    ObjC/ObjCWrapperObject.mm
    ObjC/TNSArrayAdapter.mm
    ObjC/TNSDictionaryAdapter.mm
    Runtime/JSWeakRefConstructor.cpp
    Runtime/JSWeakRefInstance.cpp
    Runtime/JSWeakRefPrototype.cpp
    SymbolLoader.mm
    TNSRuntime+Diagnostics.mm
    TNSRuntime+Inspector.mm
    TNSRuntime.mm
    TypeFactory.mm
)

set(JSFILES
    require.js
    __extends.js
    inlineFunctions.js
)

add_definitions(
    -DSTATICALLY_LINKED_WITH_JavaScriptCore
    -DSTATICALLY_LINKED_WITH_WTF
    -DENABLE_REMOTE_INSPECTOR=0
    -DENABLE_YARR_JIT=0
    -DENABLE_INSPECTOR=1
    -DENABLE_LLINT_C_LOOP=0
    -DJSC_OBJC_API_ENABLED=0
    -DHAVE_HEADER_DETECTION_H
    -DNDEBUG
    -DCURRENT_ARCH="$(CURRENT_ARCH)"
)
include(FeatureDefines.cmake)

include_directories("${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/**" "${LIBFFI_DIR}/include" "${WEBKIT_DIR}/include")

add_library(NativeScript ${SOURCE_FILES} ${HEADER_FILES} ${JSFILES})

set_target_properties(NativeScript PROPERTIES
    COMPILE_FLAGS "
        -fno-exceptions -fno-rtti -fno-objc-arc
        -Werror -Wall -Wextra -Wcast-align -Wformat-security -Wmissing-format-attribute -Wpointer-arith -Wundef -Wwrite-strings
        -Wno-shorten-64-to-32 -Wno-bool-conversion -Wno-unused-parameter
    "
    STATIC_LIBRARY_FLAGS "
        -lJavaScriptCore -L\"${WEBKIT_DIR}/lib\"
        -lffi -L\"${LIBFFI_DIR}/lib\"
    "
    XCODE_ATTRIBUTE_GCC_SYMBOLS_PRIVATE_EXTERN YES
)

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
