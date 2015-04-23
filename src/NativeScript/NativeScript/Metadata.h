//
//  Metadata.h
//  NativeScript
//
//  Created by Ivan Buhov on 8/1/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__Metadata__
#define __NativeScript__Metadata__

#include <vector>
#include <stack>
#include <string>
#include <type_traits>
#include "MetaFileReader.h"

namespace Metadata {

struct Meta;
struct ProtocolMeta;
struct MemberMeta;

template <class T>
class MemberMetaIterator {
    static_assert(std::is_convertible<T, MemberMeta>::value, "The template parameter must be an MemberMeta type.");

    inline friend bool operator==(const MemberMetaIterator& a, const MemberMetaIterator& b) {
        return a.offset == b.offset;
    }

    inline friend bool operator!=(const MemberMetaIterator& a, const MemberMetaIterator& b) {
        return !operator==(a, b);
    }

private:
    int currentIndex;
    T* currentMeta;
    MetaArrayCount count;
    MetaFileOffset offset;

    T* memberAt(int index) {
        return (T*)getMetadata()->moveInHeap(this->offset)->moveWithCounts(1)->moveWithOffsets(index)->follow()->readMeta();
    }

    MetaArrayCount membersCount() {
        return (offset == 0) ? 0 : getMetadata()->moveInHeap(this->offset)->readArrayCount();
    }

    void findNextMeta() {
        while (this->hasNext() && (this->currentMeta = this->memberAt(this->currentIndex)) == nullptr) {
            this->currentIndex++;
        }
    }

public:
    MemberMetaIterator(MetaFileOffset offset) {
        this->offset = offset;
        this->count = this->membersCount();
        this->reset();
    }

    void reset() {
        this->currentIndex = 0;
        this->findNextMeta();
    }

    void next() {
        this->currentIndex++;
        this->findNextMeta();
    }

    void jumpTo(int index) {
        if (index >= 0 && index < this->count) {
            this->currentIndex = index;
            this->findNextMeta();
        }
    }

    MemberMetaIterator& operator++() {
        this->next();
        return *this;
    }

    bool hasNext() {
        return this->currentIndex < this->count;
    }

    T* currentItem() {
        return this->currentMeta;
    }

    T* operator*() {
        return this->currentItem();
    }
};

class ProtocolIterator {
private:
    ProtocolMeta* currentMeta;
    int currentIndex;
    MetaArrayCount count;
    MetaFileOffset _protocolsOffset;

    const char* protocolJsNameAt(int index) const {
        return getMetadata()->moveInHeap(this->_protocolsOffset)->moveWithCounts(1)->moveWithOffsets(index)->follow()->readString();
    }

    ProtocolMeta* protocolAt(int index) const {
        const char* protocolName = this->protocolJsNameAt(index);
        return (ProtocolMeta*)getMetadata()->findMeta(protocolName);
    }

    MetaArrayCount protocolsCount() const {
        return (this->_protocolsOffset == 0) ? 0 : getMetadata()->moveInHeap(this->_protocolsOffset)->readArrayCount();
    }

    void findNextMeta() {
        while (this->hasNext() && (this->currentMeta = this->protocolAt(this->currentIndex)) == nullptr) {
            this->currentIndex++;
        }
    }

public:
    ProtocolIterator(MetaFileOffset offset) {
        this->_protocolsOffset = offset;
        this->count = this->protocolsCount();
        this->reset();
    }

    void reset() {
        this->currentIndex = 0;
        this->findNextMeta();
    }

    void next() {
        this->currentIndex++;
        this->findNextMeta();
    }

    void jumpTo(int index) {
        if (index >= 0 && index < this->count) {
            this->currentIndex = index;
            this->findNextMeta();
        }
    }

    ProtocolIterator& operator++() {
        this->next();
        return *this;
    }

    bool hasNext() {
        return this->currentIndex < this->count;
    }

    ProtocolMeta* currentItem() {
        return this->currentMeta;
    }

    ProtocolMeta* operator*() {
        return this->currentItem();
    }
};

// Bit indices in flags section
static const int MetaTypeMask = 7; // 0000 0111

static const int MetaHasNameBitIndex = 7;
static const int MetaIsIosAppExtensionAvailableBitIndex = 6;

static const int FunctionIsVariadicBitIndex = 5;
static const int FunctionOwnsReturnedCocoaObjectBitIndex = 4;

static const int MemberIsLocalJsNameDuplicateBitIndex = 0;
static const int MemberHasJsNameDuplicateInHierarchyBitIndex = 1;

static const int MethodIsVariadicBitIndex = 2;
static const int MethodIsNullTerminatedVariadicBitIndex = 3;
static const int MethodOwnsReturnedCocoaObjectBitIndex = 4;

static const int PropertyHasGetterBitIndex = 2;
static const int PropertyHasSetterBitIndex = 3;

enum MetaType {
    Undefined = 0,
    Struct = 1,
    Union = 2,
    Function = 3,
    JsCode = 4,
    Var = 5,
    Interface = 6,
    ProtocolType = 7
};

enum MemberType {
    InstanceMethod = 0,
    StaticMethod = 1,
    Property = 2
};

enum BinaryTypeEncodingType : Byte {
    UnknownEncoding,
    VoidEncoding,
    BoolEncoding,
    ShortEncoding,
    UShortEncoding,
    IntEncoding,
    UIntEncoding,
    LongEncoding,
    ULongEncoding,
    LongLongEncoding,
    ULongLongEncoding,
    CharEncoding,
    UCharEncoding,
    UnicharEncoding,
    CharSEncoding,
    CStringEncoding,
    FloatEncoding,
    DoubleEncoding,
    InterfaceDeclarationReference,
    StructDeclarationReference,
    UnionDeclarationReference,
    InterfaceDeclarationEncoding, // NSString* -> DeclarationReference, NSString -> InterfaceDeclaration
    PointerEncoding,
    VaListEncoding,
    SelectorEncoding,
    ClassEncoding,
    ProtocolEncoding,
    InstanceTypeEncoding,
    IdEncoding,
    ConstantArrayEncoding,
    IncompleteArrayEncoding,
    FunctionPointerEncoding,
    BlockEncoding,
    AnonymousStructEncoding,
    AnonymousUnionEncodingn
};

bool startsWith(const char* pre, const char* str);

#pragma pack(push, 1)

struct Meta {

private:
    MetaFileOffset _names;
    UInt8 _flags;
    UInt16 _frameworkId;
    UInt8 _introduced;

public:
    MetaType type() const {
        return (MetaType)(this->_flags & MetaTypeMask);
    }

    const char* moduleName() const {
        return getMetadata()->moveInHeap(this->_frameworkId)->readString();
    }

    bool hasName() const {
        return this->flag(MetaHasNameBitIndex);
    }

    bool IsIosAppExtensionAvailable() const {
        return this->flag(MetaIsIosAppExtensionAvailableBitIndex);
    }

    bool flag(int index) const {
        return (this->_flags & (1 << index)) > 0;
    }

    const char* jsName() const {
        getMetadata()->moveInHeap(this->_names);
        return (this->hasName()) ? getMetadata()->follow()->readString() : getMetadata()->readString();
    }

    const char* name() const {
        getMetadata()->moveInHeap(this->_names);
        return (this->hasName()) ? getMetadata()->moveWithOffsets(1)->follow()->readString() : getMetadata()->readString();
    }

    const char* key() const {
        return this->jsName();
    }

    /**
     * \brief The version number in which this entity was introduced.
     */
    UInt8 introducedIn() const {
        return this->_introduced;
    }

    /**
    * \brief Checks if the specified object is callable
    * from the current device.
    *
    * To be callable, an object must either:
    * > not have platform availability specified;
    * > have been introduced in this or prior version;
    */
    bool isAvailable() const;

    const void* info() const {
        return (const void*)(this + 1);
    }

#if DEBUG
    void logMeta() const {
        const char* realName = this->hasName() ? this->name() : "";
        printf("name: %s(%s) frmwk: %s", this->jsName(), realName, this->moduleName());
    }
#endif
};

struct RecordMeta : Meta {

private:
    MetaFileOffset _fieldsNames;
    MetaFileOffset _fieldsEncodings;

public:
    size_t fieldsCount() const {
        return getMetadata()->moveInHeap(this->_fieldsEncodings)->readByte();
    }

    const char* fieldAt(int index) const {
        return getMetadata()->moveInHeap(this->_fieldsNames)->moveWithCounts(1)->moveWithOffsets(index)->follow()->readString();
    }

    MetaFileOffset fieldsEncodingsOffset() const {
        return getMetadata()->moveInHeap(this->_fieldsEncodings)->moveWithCounts(1)->asOffsetInHeap();
    }

#if DEBUG
    void logRecord() const;
#endif
};

struct StructMeta : RecordMeta {
};

struct UnionMeta : RecordMeta {
};

struct FunctionMeta : Meta {

private:
    MetaFileOffset _encoding;

public:
    bool isVariadic() const {
        return this->flag(FunctionIsVariadicBitIndex);
    }

    MetaFileOffset encodingOffset() const {
        return getMetadata()->moveInHeap(this->_encoding)->moveWithCounts(1)->asOffsetInHeap();
    }

    size_t encodingCount() const {
        return getMetadata()->moveInHeap(this->_encoding)->readByte();
    }

    bool ownsReturnedCocoaObject() const {
        return this->flag(FunctionOwnsReturnedCocoaObjectBitIndex);
    }

#if DEBUG
    void logFunction() const {
        Meta::logMeta();
        //        printf(" encoding: %s, %s ", this->encoding(), this->isVariadic() ? "variadic" : "");
    }
#endif
};

struct JsCodeMeta : Meta {

private:
    MetaFileOffset _jsCode;

public:
    const char* jsCode() const {
        return getMetadata()->moveInHeap(this->_jsCode)->readString();
    }

#if DEBUG
    void logJsCode() const {
        Meta::logMeta();
        printf("Js Code: %s ", this->jsCode());
    }
#endif
};

struct VarMeta : Meta {

private:
    MetaFileOffset _encoding;

public:
    MetaFileOffset encodingOffset() const {
        return getMetadata()->moveInHeap(this->_encoding)->asOffsetInHeap();
    }

#if DEBUG
    void logVar() const {
        Meta::logMeta();
        //        printf("encoding: %s ", this->encoding());
    }
#endif
};

struct MemberMeta : Meta {

public:
    bool isLocalDuplicate() const {
        return this->flag(MemberIsLocalJsNameDuplicateBitIndex);
    }

    bool hasDuplicatesInHierarchy() const {
        return this->flag(MemberHasJsNameDuplicateInHierarchyBitIndex);
    }
};

struct MethodMeta : MemberMeta {

private:
    MetaFileOffset _selector;
    MetaFileOffset _encoding;
    MetaFileOffset _compilerEncoding;

public:
    bool isVariadic() const {
        return this->flag(MethodIsVariadicBitIndex);
    }

    bool isVariadicNullTerminated() const {
        return this->flag(MethodIsNullTerminatedVariadicBitIndex);
    }

    SEL selector() const {
        return sel_registerName(this->selectorAsString());
    }

    const char* selectorAsString() const {
        return getMetadata()->moveInHeap(this->_selector)->readString();
    }

    MetaFileOffset encodingOffset() const {
        return getMetadata()->moveInHeap(this->_encoding)->moveWithCounts(1)->asOffsetInHeap();
    }

    size_t encodingCount() const {
        return getMetadata()->moveInHeap(this->_encoding)->readByte();
    }

    const char* compilerEncoding() const {
        return getMetadata()->moveInHeap(this->_compilerEncoding)->readString();
    }

    bool ownsReturnedCocoaObject() const {
        return this->flag(MethodOwnsReturnedCocoaObjectBitIndex);
    }

#if DEBUG
    void logMethod() const {
        Meta::logMeta();
        //        printf("selector: %s encoding: %s compilerEncoding: %s ", this->selectorAsString(), this->encoding(), this->compilerEncoding());
    }
#endif
};

struct PropertyMeta : MemberMeta {

public:
    bool hasGetter() const {
        return this->flag(PropertyHasGetterBitIndex);
    }

    bool hasSetter() const {
        return this->flag(PropertyHasSetterBitIndex);
    }

    MethodMeta* getter() const {
        if (this->hasGetter()) {
            return (MethodMeta*)getMetadata()->moveToPointer(this->info())->follow()->readMeta();
        }
        return nullptr;
    }

    MethodMeta* setter() const {
        if (this->hasSetter()) {
            int offset = this->hasGetter() ? 1 : 0;
            return (MethodMeta*)getMetadata()->moveToPointer(this->info())->moveWithOffsets(offset)->follow()->readMeta();
        }
        return nullptr;
    }

#if DEBUG
    void logProperty() const {
        Meta::logMeta();
        printf(" getter: %s setter: %s ", this->hasGetter() ? this->getter()->jsName() : "", this->hasSetter() ? this->setter()->jsName() : "");
    }
#endif
};

struct BaseClassMeta : Meta {

private:
    MetaFileOffset _instanceMethods;
    MetaFileOffset _staticMethods;
    MetaFileOffset _properties;
    MetaFileOffset _protocols;
    int16_t _initializersStartIndex;

public:
    MetaFileOffset offsetOf(MemberType type) const;

    MemberMeta* member(const char* identifier, size_t length, MemberType type, bool includeProtocols = true) const;

    MemberMeta* member(StringImpl* identifier, MemberType type, bool includeProtocols = true) const {
        const char* identif = (const char*)identifier->characters8();
        size_t length = (size_t)identifier->length();
        return this->member(identif, length, type, includeProtocols);
    }

    MemberMeta* member(const char* identifier, MemberType type, bool includeProtocols = true) const {
        return this->member(identifier, strlen(identifier), type, includeProtocols);
    }

    /// instance methods

    MethodMeta* instanceMethod(const char* identifier, bool includeProtocols = true) const {
        return (MethodMeta*)this->member(identifier, MemberType::InstanceMethod, includeProtocols);
    }

    MethodMeta* instanceMethod(StringImpl* identifier, bool includeProtocols = true) const {
        return (MethodMeta*)this->member(identifier, MemberType::InstanceMethod, includeProtocols);
    }

    MemberMetaIterator<MethodMeta> getInstanceMethodsIterator() const {
        return MemberMetaIterator<MethodMeta>(this->_instanceMethods);
    }

    /// static methods

    MethodMeta* staticMethod(const char* identifier, bool includeProtocols = true) const {
        return (MethodMeta*)this->member(identifier, MemberType::StaticMethod, includeProtocols);
    }

    MethodMeta* staticMethod(StringImpl* identifier, bool includeProtocols = true) const {
        return (MethodMeta*)this->member(identifier, MemberType::StaticMethod, includeProtocols);
    }

    MemberMetaIterator<MethodMeta> getStaticMethodsIterator() const {
        return MemberMetaIterator<MethodMeta>(this->_staticMethods);
    }

    /// properties

    PropertyMeta* property(const char* identifier, bool includeProtocols = true) const {
        return (PropertyMeta*)this->member(identifier, MemberType::Property, includeProtocols);
    }

    PropertyMeta* property(StringImpl* identifier, bool includeProtocols = true) const {
        return (PropertyMeta*)this->member(identifier, MemberType::Property, includeProtocols);
    }

    MemberMetaIterator<PropertyMeta> getPropertiesIterator() const {
        return MemberMetaIterator<PropertyMeta>(this->_properties);
    }

    /// protocols

    const char* protocolJsNameAt(int index) const {
        return getMetadata()->moveInHeap(this->_protocols)->moveWithCounts(1)->moveWithOffsets(index)->follow()->readString();
    }

    ProtocolMeta* protocolAt(int index) const {
        const char* protocolName = this->protocolJsNameAt(index);
        return (ProtocolMeta*)getMetadata()->findMeta(protocolName);
    }

    MetaArrayCount protocolsCount() const {
        return (this->_protocols == 0) ? 0 : getMetadata()->moveInHeap(this->_protocols)->readArrayCount();
    }

    ProtocolIterator getProtocolsIterator() const {
        return ProtocolIterator(this->_protocols);
    }

    /// vectors

    std::vector<PropertyMeta*> properties() {
        std::vector<PropertyMeta*> properties;
        return this->properties(properties);
    }

    std::vector<PropertyMeta*> propertiesWithProtocols() {
        std::vector<PropertyMeta*> properties;
        return this->propertiesWithProtocols(properties);
    }

    std::vector<PropertyMeta*> properties(std::vector<PropertyMeta*>& container) {
        for (auto propertyIter = this->getPropertiesIterator(); propertyIter.hasNext(); propertyIter.next()) {
            container.push_back(propertyIter.currentItem());
        }
        return container;
    }

    std::vector<PropertyMeta*> propertiesWithProtocols(std::vector<PropertyMeta*>& container);

    int16_t initializersStartIndex() const {
        return this->_initializersStartIndex;
    }

    std::vector<MethodMeta*> initializers() const {
        std::vector<MethodMeta*> initializers;
        return this->initializers(initializers);
    }

    std::vector<MethodMeta*> initializersWithProtcols() const {
        std::vector<MethodMeta*> initializers;
        return this->initializersWithProtcols(initializers);
    }

    std::vector<MethodMeta*> initializers(std::vector<MethodMeta*>& container) const;

    std::vector<MethodMeta*> initializersWithProtcols(std::vector<MethodMeta*>& container) const;

#if DEBUG
    void logBaseClass() const;
#endif
};

struct ProtocolMeta : BaseClassMeta {
};

struct InterfaceMeta : BaseClassMeta {

private:
    MetaFileOffset _baseName;

public:
    const char* baseName() const {
        return this->_baseName ? getMetadata()->moveInHeap(this->_baseName)->readString() : nullptr;
    }

    const InterfaceMeta* baseMeta() const {
        return this->_baseName ? (const InterfaceMeta*)getMetadata()->findMeta(this->baseName()) : nullptr;
    }

#if DEBUG
    void logInterface() const {
        BaseClassMeta::logBaseClass();
        printf("\nbase: %s ", this->baseName());
    }
#endif
};

#pragma pack(pop)
}

#endif /* defined(__NativeScript__Metadata__) */
