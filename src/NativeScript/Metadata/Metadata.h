//
//  Metadata.h
//  NativeScript
//
//  Created by Ivan Buhov on 8/1/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__Metadata__
#define __NativeScript__Metadata__

#include <set>
#include <stack>
#include <string>
#include <type_traits>
#include <vector>

#include "KnownUnknownClassPair.h"

namespace Metadata {

static const int MetaTypeMask = 0b00000111;

template <typename V>
static const V& getProperFunctionFromContainer(const std::vector<V>& container, int argsCount, std::function<int(const V&)> paramsCounter) {
    const V* callee = nullptr;

    for (const V& func : container) {
        auto candidateArgs = paramsCounter(func);
        auto calleeArgs = 0;
        if (candidateArgs == argsCount) {
            callee = &func;
            break;
        } else if (!callee) {
            // no candidates so far, take it whatever it is
            callee = &func;
            calleeArgs = candidateArgs;
        } else if (argsCount < candidateArgs && (calleeArgs < argsCount || candidateArgs < calleeArgs)) {
            // better candidate - looking for the least number of arguments which is more than the amount actually passed
            callee = &func;
            calleeArgs = candidateArgs;
        } else if (calleeArgs < candidateArgs) {
            // better candidate - looking for the maximum number of arguments which less than the amount actually passed (if one with more cannot be found)
            callee = &func;
            calleeArgs = candidateArgs;
        }
    }

    return *callee;
}

inline UInt8 encodeVersion(UInt8 majorVersion, UInt8 minorVersion) {
    return (majorVersion << 3) | minorVersion;
}

inline UInt8 getMajorVersion(UInt8 encodedVersion) {
    return encodedVersion >> 3;
}

inline UInt8 getMinorVersion(UInt8 encodedVersion) {
    return encodedVersion & 0b111;
}

// Bit indices in flags section
enum MetaFlags {
    HasName = 7,
    // IsIosAppExtensionAvailable = 6, the flag exists in metadata generator but we never use it in the runtime
    FunctionReturnsUnmanaged = 3,
    FunctionIsVariadic = 5,
    FunctionOwnsReturnedCocoaObject = 4,
    MemberIsOptional = 0, // Mustn't equal any Method or Property flag since it can be applicable to both
    MethodIsInitializer = 1,
    MethodIsVariadic = 2,
    MethodIsNullTerminatedVariadic = 3,
    MethodOwnsReturnedCocoaObject = 4,
    MethodHasErrorOutParameter = 5,
    PropertyHasGetter = 2,
    PropertyHasSetter = 3,

};

/// This enum describes the possible ObjectiveC entity types.
enum MetaType {
    Undefined = 0,
    Struct = 1,
    Union = 2,
    Function = 3,
    JsCode = 4,
    Var = 5,
    Interface = 6,
    ProtocolType = 7,
    Vector = 8
};

enum MemberType {
    InstanceMethod = 0,
    StaticMethod = 1,
    InstanceProperty = 2,
    StaticProperty = 3
};

enum BinaryTypeEncodingType : Byte {
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
    AnonymousUnionEncoding,
    ExtVectorEncoding
};

#pragma pack(push, 1)

template <typename T>
struct PtrTo;
struct Meta;
struct InterfaceMeta;
struct ProtocolMeta;
struct ModuleMeta;
struct LibraryMeta;
struct TypeEncoding;

typedef WTF::Vector<const ProtocolMeta*> ProtocolMetas;

typedef int32_t ArrayCount;

static const void* offset(const void* from, ptrdiff_t offset) {
    return reinterpret_cast<const char*>(from) + offset;
}

template <typename T>
struct Array {
    class iterator {
    private:
        const T* current;

    public:
        iterator(const T* item)
            : current(item) {
        }
        bool operator==(const iterator& other) const {
            return current == other.current;
        }
        bool operator!=(const iterator& other) const {
            return !(*this == other);
        }
        iterator& operator++() {
            current++;
            return *this;
        }
        iterator operator++(int) {
            iterator tmp(current);
            operator++();
            return tmp;
        }
        const T& operator*() const {
            return *current;
        }
    };

    ArrayCount count;

    const T* first() const {
        return reinterpret_cast<const T*>(&count + 1);
    }

    const T& operator[](int index) const {
        return *(first() + index);
    }

    Array<T>::iterator begin() const {
        return first();
    }

    Array<T>::iterator end() const {
        return first() + count;
    }

    template <typename V>
    const Array<V>& castTo() const {
        return *reinterpret_cast<const Array<V>*>(this);
    }

    int sizeInBytes() const {
        return sizeof(Array<T>) + sizeof(T) * count;
    }

    int binarySearch(std::function<int(const T&)> comparer) const {
        int left = 0, right = count - 1, mid;
        while (left <= right) {
            mid = (right + left) / 2;
            const T& current = (*this)[mid];
            int comparisonResult = comparer(current);
            if (comparisonResult < 0) {
                left = mid + 1;
            } else if (comparisonResult > 0) {
                right = mid - 1;
            } else {
                return mid;
            }
        }
        return -(left + 1);
    }

    int binarySearchLeftmost(std::function<int(const T&)> comparer) const {
        int mid = binarySearch(comparer);
        while (mid > 0 && comparer((*this)[mid - 1]) == 0) {
            mid -= 1;
        }
        return mid;
    }
};

template <typename T>
using ArrayOfPtrTo = Array<PtrTo<T>>;
using String = PtrTo<char>;

enum GlobalTableType {
    ByJsName,
    ByNativeName,
};

template <GlobalTableType TYPE>
struct GlobalTable {
    class iterator {
    private:
        const GlobalTable<TYPE>* _globalTable;
        int _topLevelIndex;
        int _bucketIndex;

        void findNext();

        const Meta* getCurrent();

    public:
        iterator(const GlobalTable<TYPE>* globalTable)
            : iterator(globalTable, 0, 0) {
            findNext();
        }

        iterator(const GlobalTable<TYPE>* globalTable, int32_t topLevelIndex, int32_t bucketIndex)
            : _globalTable(globalTable)
            , _topLevelIndex(topLevelIndex)
            , _bucketIndex(bucketIndex) {
            findNext();
        }

        bool operator==(const iterator& other) const;

        bool operator!=(const iterator& other) const;

        iterator& operator++();

        iterator operator++(int) {
            iterator tmp(_globalTable, _topLevelIndex, _bucketIndex);
            operator++();
            return tmp;
        }

        const Meta* operator*();
    };

    iterator begin() const {
        return iterator(this);
    }

    iterator end() const {
        return iterator(this, this->buckets.count, 0);
    }

    ArrayOfPtrTo<ArrayOfPtrTo<Meta>> buckets;

    const InterfaceMeta* findInterfaceMeta(WTF::StringImpl* identifier) const;

    const InterfaceMeta* findInterfaceMeta(const char* identifierString) const;

    const InterfaceMeta* findInterfaceMeta(const char* identifierString, size_t length, unsigned hash) const;

    const ProtocolMeta* findProtocol(WTF::StringImpl* identifier) const;

    const ProtocolMeta* findProtocol(const char* identifierString) const;

    const ProtocolMeta* findProtocol(const char* identifierString, size_t length, unsigned hash) const;

    const Meta* findMeta(WTF::StringImpl* identifier, bool onlyIfAvailable = true) const;

    const Meta* findMeta(const char* identifierString, bool onlyIfAvailable = true) const;

    const Meta* findMeta(const char* identifierString, size_t length, unsigned hash, bool onlyIfAvailable = true) const;

    int sizeInBytes() const {
        return buckets.sizeInBytes();
    }

    static const char* getName(const Meta& meta);
};

struct ModuleTable {
    ArrayOfPtrTo<ModuleMeta> modules;

    int sizeInBytes() const {
        return modules.sizeInBytes();
    }
};

struct MetaFile {
private:
    GlobalTable<GlobalTableType::ByJsName> _globalTableJs;

public:
    static MetaFile* instance();

    static MetaFile* setInstance(void* metadataPtr);

    const GlobalTable<GlobalTableType::ByJsName>* globalTableJs() const {
        return &this->_globalTableJs;
    }

    const GlobalTable<GlobalTableType::ByNativeName>* globalTableNativeProtocols() const {
        const GlobalTable<GlobalTableType::ByJsName>* gt = this->globalTableJs();
        return reinterpret_cast<const GlobalTable<GlobalTableType::ByNativeName>*>(offset(gt, gt->sizeInBytes()));
    }

    const GlobalTable<GlobalTableType::ByNativeName>* globalTableNativeInterfaces() const {
        const GlobalTable<GlobalTableType::ByNativeName>* gt = this->globalTableNativeProtocols();
        return reinterpret_cast<const GlobalTable<GlobalTableType::ByNativeName>*>(offset(gt, gt->sizeInBytes()));
    }

    const ModuleTable* topLevelModulesTable() const {
        const GlobalTable<GlobalTableType::ByNativeName>* gt = this->globalTableNativeInterfaces();
        return reinterpret_cast<const ModuleTable*>(offset(gt, gt->sizeInBytes()));
    }

    const void* heap() const {
        const ModuleTable* mt = this->topLevelModulesTable();
        return offset(mt, mt->sizeInBytes());
    }
};

template <typename T>
struct PtrTo {
    int32_t offset;

    bool isNull() const {
        return offset == 0;
    }
    PtrTo<T> operator+(int value) const {
        return add(value);
    }
    const T* operator->() const {
        return valuePtr();
    }
    PtrTo<T> add(int value) const {
        return PtrTo<T>{ .offset = this->offset + value * sizeof(T) };
    }
    PtrTo<T> addBytes(int bytes) const {
        return PtrTo<T>{ .offset = this->offset + bytes };
    }
    template <typename V>
    PtrTo<V>& castTo() const {
        return reinterpret_cast<PtrTo<V>>(this);
    }
    const T* valuePtr() const {
        return isNull() ? nullptr : reinterpret_cast<const T*>(Metadata::offset(MetaFile::instance()->heap(), this->offset));
    }
    const T& value() const {
        return *valuePtr();
    }
};

template <typename T>
struct TypeEncodingsList {
    T count;

    const TypeEncoding* first() const {
        return reinterpret_cast<const TypeEncoding*>(this + 1);
    }
};

union TypeEncodingDetails {
    struct IdDetails {
        PtrTo<Array<String>> _protocols;
    } idDetails;
    struct IncompleteArrayDetails {
        const TypeEncoding* getInnerType() const {
            return reinterpret_cast<const TypeEncoding*>(this);
        }
    } incompleteArray;
    struct ConstantArrayDetails {
        int32_t size;
        const TypeEncoding* getInnerType() const {
            return reinterpret_cast<const TypeEncoding*>(this + 1);
        }
    } constantArray;
    struct ExtVectorDetails {
        int32_t size;
        const TypeEncoding* getInnerType() const {
            return reinterpret_cast<const TypeEncoding*>(this + 1);
        }
    } extVector;
    struct DeclarationReferenceDetails {
        String name;
    } declarationReference;
    struct InterfaceDeclarationReferenceDetails {
        String name;
        PtrTo<Array<String>> _protocols;
    } interfaceDeclarationReference;
    struct PointerDetails {
        const TypeEncoding* getInnerType() const {
            return reinterpret_cast<const TypeEncoding*>(this);
        }
    } pointer;
    struct BlockDetails {
        TypeEncodingsList<uint8_t> signature;
    } block;
    struct FunctionPointerDetails {
        TypeEncodingsList<uint8_t> signature;
    } functionPointer;
    struct AnonymousRecordDetails {
        uint8_t fieldsCount;
        const String* getFieldNames() const {
            return reinterpret_cast<const String*>(this + 1);
        }
        const TypeEncoding* getFieldsEncodings() const {
            return reinterpret_cast<const TypeEncoding*>(getFieldNames() + this->fieldsCount);
        }
    } anonymousRecord;
};

struct TypeEncoding {
    BinaryTypeEncodingType type;
    TypeEncodingDetails details;

    const TypeEncoding* next() const {
        const TypeEncoding* afterTypePtr = reinterpret_cast<const TypeEncoding*>(offset(this, sizeof(type)));

        switch (this->type) {
        case BinaryTypeEncodingType::IdEncoding: {
            return reinterpret_cast<const TypeEncoding*>(offset(afterTypePtr, sizeof(TypeEncodingDetails::IdDetails)));
        }
        case BinaryTypeEncodingType::ConstantArrayEncoding: {
            return this->details.constantArray.getInnerType()->next();
        }
        case BinaryTypeEncodingType::ExtVectorEncoding: {
            return this->details.extVector.getInnerType()->next();
        }
        case BinaryTypeEncodingType::IncompleteArrayEncoding: {
            return this->details.incompleteArray.getInnerType()->next();
        }
        case BinaryTypeEncodingType::PointerEncoding: {
            return this->details.pointer.getInnerType()->next();
        }
        case BinaryTypeEncodingType::BlockEncoding: {
            const TypeEncoding* current = this->details.block.signature.first();
            for (int i = 0; i < this->details.block.signature.count; i++) {
                current = current->next();
            }
            return current;
        }
        case BinaryTypeEncodingType::FunctionPointerEncoding: {
            const TypeEncoding* current = this->details.functionPointer.signature.first();
            for (int i = 0; i < this->details.functionPointer.signature.count; i++) {
                current = current->next();
            }
            return current;
        }
        case BinaryTypeEncodingType::InterfaceDeclarationReference: {
            return reinterpret_cast<const TypeEncoding*>(offset(afterTypePtr, sizeof(TypeEncodingDetails::InterfaceDeclarationReferenceDetails)));
        }
        case BinaryTypeEncodingType::StructDeclarationReference:
        case BinaryTypeEncodingType::UnionDeclarationReference: {
            return reinterpret_cast<const TypeEncoding*>(offset(afterTypePtr, sizeof(TypeEncodingDetails::DeclarationReferenceDetails)));
        }
        case BinaryTypeEncodingType::AnonymousStructEncoding:
        case BinaryTypeEncodingType::AnonymousUnionEncoding: {
            const TypeEncoding* current = this->details.anonymousRecord.getFieldsEncodings();
            for (int i = 0; i < this->details.anonymousRecord.fieldsCount; i++) {
                current = current->next();
            }
            return current;
        }
        default: {
            return afterTypePtr;
        }
        }
    }
};

struct ModuleMeta {
public:
    UInt8 flags;
    String name;
    PtrTo<ArrayOfPtrTo<LibraryMeta>> libraries;

    const char* getName() const {
        return name.valuePtr();
    }

    bool isFramework() const {
        return (flags & 1) > 0;
    }

    bool isSystem() const {
        return (flags & 2) > 0;
    }
};

struct LibraryMeta {
public:
    UInt8 flags;
    String name;

    const char* getName() const {
        return name.valuePtr();
    }

    bool isFramework() const {
        return (flags & 1) > 0;
    }
};

struct JsNameAndName {
    String jsName;
    String name;
};

union MetaNames {
    String name;
    PtrTo<JsNameAndName> names;
};

struct Meta {

private:
    MetaNames _names;
    PtrTo<ModuleMeta> _topLevelModule;
    UInt8 _flags;
    UInt8 _introduced;

public:
    MetaType type() const {
        return (MetaType)(this->_flags & MetaTypeMask);
    }

    const ModuleMeta* topLevelModule() const {
        return this->_topLevelModule.valuePtr();
    }

    bool hasName() const {
        return this->flag(MetaFlags::HasName);
    }

    bool flag(int index) const {
        return (this->_flags & (1 << index)) > 0;
    }

    const char* jsName() const {
        return (this->hasName()) ? this->_names.names->jsName.valuePtr() : this->_names.name.valuePtr();
    }

    const char* name() const {
        return (this->hasName()) ? this->_names.names->name.valuePtr() : this->jsName();
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
};

struct RecordMeta : Meta {

private:
    PtrTo<Array<String>> _fieldsNames;
    PtrTo<TypeEncodingsList<ArrayCount>> _fieldsEncodings;

public:
    const Array<String>& fieldNames() const {
        return _fieldsNames.value();
    }

    size_t fieldsCount() const {
        return fieldNames().count;
    }

    const TypeEncodingsList<ArrayCount>* fieldsEncodings() const {
        return _fieldsEncodings.valuePtr();
    }
};

struct StructMeta : RecordMeta {
};

struct UnionMeta : RecordMeta {
};

struct FunctionMeta : Meta {

private:
    PtrTo<TypeEncodingsList<ArrayCount>> _encoding;

public:
    bool isVariadic() const {
        return this->flag(MetaFlags::FunctionIsVariadic);
    }

    const TypeEncodingsList<ArrayCount>* encodings() const {
        return _encoding.valuePtr();
    }

    bool ownsReturnedCocoaObject() const {
        return this->flag(MetaFlags::FunctionOwnsReturnedCocoaObject);
    }

    bool returnsUnmanaged() const {
        return this->flag(MetaFlags::FunctionReturnsUnmanaged);
    }
};

struct JsCodeMeta : Meta {

private:
    String _jsCode;

public:
    const char* jsCode() const {
        return _jsCode.valuePtr();
    }
};

struct VarMeta : Meta {

private:
    PtrTo<TypeEncoding> _encoding;

public:
    const TypeEncoding* encoding() const {
        return _encoding.valuePtr();
    }
};

struct MemberMeta : Meta {
    bool isOptional() const {
        return this->flag(MetaFlags::MemberIsOptional);
    }
};

struct MethodMeta : MemberMeta {

private:
    PtrTo<TypeEncodingsList<ArrayCount>> _encodings;
    String _constructorTokens;

public:
    bool isVariadic() const {
        return this->flag(MetaFlags::MethodIsVariadic);
    }

    bool isVariadicNullTerminated() const {
        return this->flag(MetaFlags::MethodIsNullTerminatedVariadic);
    }

    bool hasErrorOutParameter() const {
        return this->flag(MetaFlags::MethodHasErrorOutParameter);
    }

    bool isInitializer() const {
        return this->flag(MetaFlags::MethodIsInitializer);
    }

    bool ownsReturnedCocoaObject() const {
        return this->flag(MetaFlags::MethodOwnsReturnedCocoaObject);
    }

    SEL selector() const {
        return sel_registerName(this->selectorAsString());
    }

    // just a more convenient way to get the selector of method
    const char* selectorAsString() const {
        return this->name();
    }

    const TypeEncodingsList<ArrayCount>* encodings() const {
        return this->_encodings.valuePtr();
    }

    const char* constructorTokens() const {
        return this->_constructorTokens.valuePtr();
    }

    bool isImplementedInClass(Class klass, bool isStatic) const;
    bool isAvailableInClass(Class klass, bool isStatic) const {
        return this->isAvailable() && this->isImplementedInClass(klass, isStatic);
    }
    bool isAvailableInClasses(KnownUnknownClassPair klasses, bool isStatic) const {
        return this->isAvailableInClass(klasses.known, isStatic) || (klasses.unknown != nullptr && this->isAvailableInClass(klasses.unknown, isStatic));
    }
};

typedef HashSet<const MemberMeta*> MembersCollection;

std::unordered_map<std::string, MembersCollection> getMetasByJSNames(MembersCollection methods);

struct PropertyMeta : MemberMeta {
    PtrTo<MethodMeta> method1;
    PtrTo<MethodMeta> method2;

public:
    bool hasGetter() const {
        return this->flag(MetaFlags::PropertyHasGetter);
    }

    bool hasSetter() const {
        return this->flag(MetaFlags::PropertyHasSetter);
    }

    const MethodMeta* getter() const {
        return this->hasGetter() ? method1.valuePtr() : nullptr;
    }

    const MethodMeta* setter() const {
        return (this->hasSetter()) ? (this->hasGetter() ? method2.valuePtr() : method1.valuePtr()) : nullptr;
    }

    bool isImplementedInClass(Class klass, bool isStatic) const {
        bool getterAvailable = this->hasGetter() && this->getter()->isImplementedInClass(klass, isStatic);
        bool setterAvailable = this->hasSetter() && this->setter()->isImplementedInClass(klass, isStatic);
        return getterAvailable || setterAvailable;
    }

    bool isAvailableInClass(Class klass, bool isStatic) const {
        return this->isAvailable() && this->isImplementedInClass(klass, isStatic);
    }

    bool isAvailableInClasses(KnownUnknownClassPair klasses, bool isStatic) const {
        return this->isAvailableInClass(klasses.known, isStatic) || (klasses.unknown != nullptr && this->isAvailableInClass(klasses.unknown, isStatic));
    }
};

struct BaseClassMeta : Meta {

    PtrTo<ArrayOfPtrTo<MethodMeta>> instanceMethods;
    PtrTo<ArrayOfPtrTo<MethodMeta>> staticMethods;
    PtrTo<ArrayOfPtrTo<PropertyMeta>> instanceProps;
    PtrTo<ArrayOfPtrTo<PropertyMeta>> staticProps;
    PtrTo<Array<String>> protocols;
    int16_t initializersStartIndex;

    template <typename T>
    void forEachProtocol(const T& fun, const ProtocolMetas* additionalProtocols) const {
        for (Array<String>::iterator it = this->protocols->begin(); it != this->protocols->end(); ++it) {
            if (const ProtocolMeta* protocolMeta = MetaFile::instance()->globalTableJs()->findProtocol((*it).valuePtr())) {
                fun(protocolMeta);
            }
        }

        if (additionalProtocols) {
            for (const ProtocolMeta* protocolMeta : *additionalProtocols) {
                fun(protocolMeta);
            }
        }
    }

    std::set<const ProtocolMeta*> protocolsSet() const;

    std::set<const ProtocolMeta*> deepProtocolsSet() const;

    void deepProtocolsSet(std::set<const ProtocolMeta*>& protocols) const;

    const MemberMeta* member(const char* identifier, size_t length, MemberType type, bool includeProtocols, bool onlyIfAvailable, const ProtocolMetas& additionalProtocols) const;

    const MethodMeta* member(const char* identifier, size_t length, MemberType type, size_t paramsCount, bool includeProtocols, bool onlyIfAvailable, const ProtocolMetas& additionalProtocols) const;

    const MembersCollection members(const char* identifier, size_t length, MemberType type, bool includeProtocols, bool onlyIfAvailable, const ProtocolMetas& additionalProtocols) const;

    const MemberMeta* member(StringImpl* identifier, MemberType type, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        // Assign to a separate variable to ensure the lifetime of the string returned by utf8
        auto identifierUtf8 = identifier->utf8();
        const char* identif = reinterpret_cast<const char*>(identifierUtf8.data());
        size_t length = (size_t)identifier->length();
        return this->member(identif, length, type, includeProtocols, /*onlyIfAvailable*/ true, additionalProtocols);
    }

    const MethodMeta* member(StringImpl* identifier, MemberType type, size_t paramsCount, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        // Assign to a separate variable to ensure the lifetime of the string returned by utf8
        auto identifierUtf8 = identifier->utf8();
        const char* identif = reinterpret_cast<const char*>(identifierUtf8.data());
        size_t length = (size_t)identifier->length();
        return this->member(identif, length, type, paramsCount, includeProtocols, /*onlyIfAvailable*/ true, additionalProtocols);
    }

    const MembersCollection members(StringImpl* identifier, MemberType type, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        // Assign to a separate variable to ensure the lifetime of the string returned by utf8
        auto identifierUtf8 = identifier->utf8();
        const char* identif = reinterpret_cast<const char*>(identifierUtf8.data());
        size_t length = (size_t)identifier->length();
        return this->members(identif, length, type, includeProtocols, /*onlyIfAvailable*/ true, additionalProtocols);
    }

    const MemberMeta* member(const char* identifier, MemberType type, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        return this->member(identifier, strlen(identifier), type, includeProtocols, /*onlyIfAvailable*/ true, additionalProtocols);
    }

    const MemberMeta* deepMember(const char* identifier, size_t length, MemberType type, bool includeProtocols, bool onlyIfAvailable, const ProtocolMetas& additionalProtocols) const;

    const MemberMeta* deepMember(StringImpl* identifier, MemberType type, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        // Assign to a separate variable to ensure the lifetime of the string returned by utf8
        auto identifierUtf8 = identifier->utf8();
        const char* identif = reinterpret_cast<const char*>(identifierUtf8.data());
        size_t length = (size_t)identifier->length();
        return this->deepMember(identif, length, type, includeProtocols, /*onlyIfAvailable*/ true, additionalProtocols);
    }

    const MemberMeta* deepMember(const char* identifier, MemberType type, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        return this->deepMember(identifier, strlen(identifier), type, includeProtocols, /*onlyIfAvailable*/ true, additionalProtocols);
    }

    /// instance methods
    const MethodMeta* instanceMethod(const char* identifier, KnownUnknownClassPair klasses, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        auto methodMeta = static_cast<const MethodMeta*>(this->member(identifier, MemberType::InstanceMethod, includeProtocols, additionalProtocols));
        return methodMeta && methodMeta->isAvailableInClasses(klasses, /*isStatic*/ false) ? methodMeta : nullptr;
    }

    const MethodMeta* instanceMethod(StringImpl* identifier, KnownUnknownClassPair klasses, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        auto methodMeta = static_cast<const MethodMeta*>(this->member(identifier, MemberType::InstanceMethod, includeProtocols, additionalProtocols));
        return methodMeta && methodMeta->isAvailableInClasses(klasses, /*isStatic*/ false) ? methodMeta : nullptr;
    }

    const MethodMeta* deepInstanceMethod(const char* identifier, KnownUnknownClassPair klasses, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        auto methodMeta = static_cast<const MethodMeta*>(this->deepMember(identifier, MemberType::InstanceMethod, includeProtocols, additionalProtocols));
        return methodMeta && methodMeta->isAvailableInClasses(klasses, /*isStatic*/ false) ? methodMeta : nullptr;
    }

    const MethodMeta* deepInstanceMethod(StringImpl* identifier, KnownUnknownClassPair klasses, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        auto methodMeta = static_cast<const MethodMeta*>(this->deepMember(identifier, MemberType::InstanceMethod, includeProtocols, additionalProtocols));
        return methodMeta && methodMeta->isAvailableInClasses(klasses, /*isStatic*/ false) ? methodMeta : nullptr;
    }

    // Remove all optional methods/properties which are not implemented in the class
    template <typename TMemberMeta>
    static void filterUnavailableMembers(MembersCollection& members, KnownUnknownClassPair klasses, bool isStatic) {
        members.removeIf([klasses, isStatic](const MemberMeta* memberMeta) {
            return !static_cast<const TMemberMeta*>(memberMeta)->isAvailableInClasses(klasses, isStatic);
        });
    }

    const MembersCollection getInstanceMethods(StringImpl* identifier, KnownUnknownClassPair klasses, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        MembersCollection methods = this->members(identifier, MemberType::InstanceMethod, includeProtocols, additionalProtocols);

        filterUnavailableMembers<MethodMeta>(methods, klasses, false);

        return methods;
    }

    /// static methods
    const MembersCollection getStaticMethods(StringImpl* identifier, KnownUnknownClassPair klasses, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        MembersCollection methods = this->members(identifier, MemberType::StaticMethod, includeProtocols, additionalProtocols);

        filterUnavailableMembers<MethodMeta>(methods, klasses, true);

        return methods;
    }

    /// instance properties
    const PropertyMeta* instanceProperty(const char* identifier, KnownUnknownClassPair klasses, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        auto propMeta = static_cast<const PropertyMeta*>(this->member(identifier, MemberType::InstanceProperty, includeProtocols, additionalProtocols));
        return propMeta && propMeta->isAvailableInClasses(klasses, /*isStatic*/ false) ? propMeta : nullptr;
    }

    const PropertyMeta* instanceProperty(StringImpl* identifier, KnownUnknownClassPair klasses, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        auto propMeta = static_cast<const PropertyMeta*>(this->member(identifier, MemberType::InstanceProperty, includeProtocols, additionalProtocols));
        return propMeta && propMeta->isAvailableInClasses(klasses, /*isStatic*/ false) ? propMeta : nullptr;
    }

    const PropertyMeta* deepInstanceProperty(const char* identifier, KnownUnknownClassPair klasses, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        auto propMeta = static_cast<const PropertyMeta*>(this->deepMember(identifier, MemberType::InstanceProperty, includeProtocols, additionalProtocols));
        return propMeta && propMeta->isAvailableInClasses(klasses, /*isStatic*/ false) ? propMeta : nullptr;
    }

    const PropertyMeta* deepInstanceProperty(StringImpl* identifier, KnownUnknownClassPair klasses, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        auto propMeta = static_cast<const PropertyMeta*>(this->deepMember(identifier, MemberType::InstanceProperty, includeProtocols, additionalProtocols));
        return propMeta && propMeta->isAvailableInClasses(klasses, /*isStatic*/ false) ? propMeta : nullptr;
    }

    /// static properties
    const PropertyMeta* staticProperty(const char* identifier, KnownUnknownClassPair klasses, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        auto propMeta = static_cast<const PropertyMeta*>(this->member(identifier, MemberType::StaticProperty, includeProtocols, additionalProtocols));
        return propMeta && propMeta->isAvailableInClasses(klasses, /*isStatic*/ true) ? propMeta : nullptr;
    }

    const PropertyMeta* staticProperty(StringImpl* identifier, KnownUnknownClassPair klasses, bool includeProtocols, const ProtocolMetas& additionalProtocols) const {
        auto propMeta = static_cast<const PropertyMeta*>(this->member(identifier, MemberType::StaticProperty, includeProtocols, additionalProtocols));
        return propMeta && propMeta->isAvailableInClasses(klasses, /*isStatic*/ true) ? propMeta : nullptr;
    }

    /// vectors
    std::vector<const PropertyMeta*> instanceProperties(KnownUnknownClassPair klasses) const {
        std::vector<const PropertyMeta*> properties;
        return this->instanceProperties(properties, klasses);
    }

    std::vector<const PropertyMeta*> instancePropertiesWithProtocols(KnownUnknownClassPair klasses, const ProtocolMetas& additionalProtocols) const {
        std::vector<const PropertyMeta*> properties;
        return this->instancePropertiesWithProtocols(properties, klasses, additionalProtocols);
    }

    std::vector<const PropertyMeta*> instanceProperties(std::vector<const PropertyMeta*>& container, KnownUnknownClassPair klasses) const {
        for (Array<PtrTo<PropertyMeta>>::iterator it = this->instanceProps->begin(); it != this->instanceProps->end(); it++) {
            if ((*it)->isAvailableInClasses(klasses, /*isStatic*/ false)) {
                container.push_back((*it).valuePtr());
            }
        }
        return container;
    }

    std::vector<const PropertyMeta*> instancePropertiesWithProtocols(std::vector<const PropertyMeta*>& container, KnownUnknownClassPair klasses, const ProtocolMetas& additionalProtocols) const;

    std::vector<const PropertyMeta*> staticProperties(KnownUnknownClassPair klasses) const {
        std::vector<const PropertyMeta*> properties;
        return this->staticProperties(properties, klasses);
    }

    std::vector<const PropertyMeta*> staticPropertiesWithProtocols(KnownUnknownClassPair klasses, const ProtocolMetas& additionalProtocols) const {
        std::vector<const PropertyMeta*> properties;
        return this->staticPropertiesWithProtocols(properties, klasses, additionalProtocols);
    }

    std::vector<const PropertyMeta*> staticProperties(std::vector<const PropertyMeta*>& container, KnownUnknownClassPair klasses) const {
        for (Array<PtrTo<PropertyMeta>>::iterator it = this->staticProps->begin(); it != this->staticProps->end(); it++) {
            if ((*it)->isAvailableInClasses(klasses, /*isStatic*/ true)) {
                container.push_back((*it).valuePtr());
            }
        }
        return container;
    }

    std::vector<const PropertyMeta*> staticPropertiesWithProtocols(std::vector<const PropertyMeta*>& container, KnownUnknownClassPair klasses, const ProtocolMetas& additionalProtocols) const;

    std::vector<const MethodMeta*> initializers(KnownUnknownClassPair klasses) const {
        std::vector<const MethodMeta*> initializers;
        return this->initializers(initializers, klasses);
    }

    std::vector<const MethodMeta*> initializersWithProtocols(KnownUnknownClassPair klasses, const ProtocolMetas& additionalProtocols) const {
        std::vector<const MethodMeta*> initializers;
        return this->initializersWithProtocols(initializers, klasses, additionalProtocols);
    }

    std::vector<const MethodMeta*> initializers(std::vector<const MethodMeta*>& container, KnownUnknownClassPair klasses) const;

    std::vector<const MethodMeta*> initializersWithProtocols(std::vector<const MethodMeta*>& container, KnownUnknownClassPair klasses, const ProtocolMetas& additionalProtocols) const;
};

struct ProtocolMeta : BaseClassMeta {
};

struct InterfaceMeta : BaseClassMeta {

private:
    String _baseName;

public:
    const char* baseName() const {
        return _baseName.valuePtr();
    }

    const InterfaceMeta* baseMeta() const {
        if (this->baseName() != nullptr) {
            const InterfaceMeta* baseMeta = MetaFile::instance()->globalTableJs()->findInterfaceMeta(this->baseName());
            return baseMeta;
        }

        return nullptr;
    }
};

#pragma pack(pop)

} // namespace Metadata

#include "MetadataInlines.h"

#endif /* defined(__NativeScript__Metadata__) */
