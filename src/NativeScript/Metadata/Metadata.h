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

namespace Metadata {

static const int MetaTypeMask = 7; // 0000 0111

// Bit indices in flags section
enum MetaFlags {
    HasName = 7,
    FunctionIsVariadic = 5,
    FunctionOwnsReturnedCocoaObject = 4,
    MethodIsVariadic = 2,
    MethodIsNullTerminatedVariadic = 3,
    MethodOwnsReturnedCocoaObject = 4,
    PropertyHasGetter = 2,
    PropertyHasSetter = 3
};

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
    AnonymousUnionEncoding
};

#pragma pack(push, 1)

template <typename T>
struct PtrTo;
struct Meta;
struct ProtocolMeta;
struct ModuleMeta;
struct LibraryMeta;
struct TypeEncoding;

typedef int32_t ArrayCount;

template <typename T>
struct Array {
    class iterator {
    private:
        T* current;

    public:
        iterator(T* item)
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
        T& operator*() const {
            return *current;
        }
    };

    ArrayCount count;

    T* first() const {
        return (T*)(&count + 1);
    }

    T& operator[](int index) const {
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
            const T& current = (*this)[mid]; //this[mid];
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
};

template <typename T>
using ArrayOfPtrTo = Array<PtrTo<T>>;
using String = PtrTo<char>;

struct GlobalTable {
    class iterator {
    private:
        const GlobalTable* _globalTable;
        int _topLevelIndex;
        int _bucketIndex;

        void findNext();

        const Meta* getCurrent();

    public:
        iterator(const GlobalTable* globalTable)
            : iterator(globalTable, 0, 0) {
            findNext();
        }

        iterator(const GlobalTable* globalTable, int32_t topLevelIndex, int32_t bucketIndex)
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

    const Meta* findMeta(WTF::StringImpl* identifier, bool onlyIfAvailable = true) const;

    const Meta* findMeta(const char* identifierString, bool onlyIfAvailable = true) const;

    const Meta* findMeta(const char* identifierString, size_t length, unsigned hash, bool onlyIfAvailable = true) const;

    int sizeInBytes() const {
        return buckets.sizeInBytes();
    }
};

struct ModuleTable {
    ArrayOfPtrTo<ModuleMeta> modules;

    int sizeInBytes() const {
        return modules.sizeInBytes();
    }
};

struct MetaFile {
private:
    GlobalTable _globalTable;

public:
    static MetaFile* instance();

    const GlobalTable* globalTable() const {
        return &this->_globalTable;
    }

    const ModuleTable* topLevelModulesTable() const {
        const GlobalTable* gt = this->globalTable();
        return (ModuleTable*)((char*)gt + gt->sizeInBytes());
    }

    void* heap() const {
        const ModuleTable* mt = this->topLevelModulesTable();
        return (char*)mt + mt->sizeInBytes();
    }
};

template <typename T>
struct PtrTo {
    int32_t offset;

    bool isNull() const {
        return offset == 0;
    }
    //operator bool() const { return !isNull(); }
    PtrTo<T> operator+(int value) const {
        return add(value);
    }
    T* operator->() const {
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
    T* valuePtr() const {
        return isNull() ? nullptr : (T*)((char*)MetaFile::instance()->heap() + this->offset);
    }
    T& value() const {
        return *valuePtr();
    }
};

template <typename T>
struct TypeEncodingsList {
    T _count;

    TypeEncoding* first() {
        return (TypeEncoding*)(this + 1);
    }
};

union TypeEncodingDetails {
    struct IncompleteArrayDetails {
        TypeEncoding* getInnerType() {
            return (TypeEncoding*)this;
        }
    } incompleteArray;
    struct ConstantArrayDetails {
        int32_t size;
        TypeEncoding* getInnerType() {
            return (TypeEncoding*)(this + 1);
        }
    } constantArray;
    struct DeclarationReferenceDetails {
        String name;
    } declarationReference;
    struct PointerDetails {
        TypeEncoding* getInnerType() {
            return (TypeEncoding*)this;
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
        String* getFieldNames() {
            return (String*)(this + 1);
        }
        TypeEncoding* getFieldsEncodings() {
            return (TypeEncoding*)(getFieldNames() + this->fieldsCount);
        }
    } anonymousRecord;
};

struct TypeEncoding {
    BinaryTypeEncodingType type;
    TypeEncodingDetails details;

    TypeEncoding* next() {
        TypeEncoding* afterTypePtr = (TypeEncoding*)((char*)this + sizeof(type));

        switch (this->type) {
        case BinaryTypeEncodingType::ConstantArrayEncoding: {
            return this->details.constantArray.getInnerType()->next();
        }
        case BinaryTypeEncodingType::IncompleteArrayEncoding: {
            return this->details.incompleteArray.getInnerType()->next();
        }
        case BinaryTypeEncodingType::PointerEncoding: {
            return this->details.pointer.getInnerType()->next();
        }
        case BinaryTypeEncodingType::BlockEncoding: {
            TypeEncoding* current = this->details.block.signature.first();
            for (int i = 0; i < this->details.block.signature._count; i++) {
                current = current->next();
            }
            return current;
        }
        case BinaryTypeEncodingType::FunctionPointerEncoding: {
            TypeEncoding* current = this->details.functionPointer.signature.first();
            for (int i = 0; i < this->details.functionPointer.signature._count; i++) {
                current = current->next();
            }
            return current;
        }
        case BinaryTypeEncodingType::InterfaceDeclarationReference:
        case BinaryTypeEncodingType::StructDeclarationReference:
        case BinaryTypeEncodingType::UnionDeclarationReference: {
            return (TypeEncoding*)((char*)afterTypePtr + sizeof(TypeEncodingDetails::DeclarationReferenceDetails));
        }
        case BinaryTypeEncodingType::AnonymousStructEncoding:
        case BinaryTypeEncodingType::AnonymousUnionEncoding: {
            TypeEncoding* current = this->details.anonymousRecord.getFieldsEncodings();
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
    UInt8 _flags;
    String _name;
    PtrTo<ArrayOfPtrTo<LibraryMeta>> _libraries;

    const char* name() const {
        return _name.valuePtr();
    }

    bool isFramework() {
        return (_flags & 1) > 0;
    }

    bool isSystem() {
        return (_flags & 2) > 0;
    }
};

struct LibraryMeta {
public:
    UInt8 _flags;
    String _name;

    const char* name() const {
        return _name.valuePtr();
    }

    bool isFramework() {
        return (_flags & 1) > 0;
    }
};

struct JsNameAndName {
    String jsName;
    String name;
};

union MetaNames {
    String _name;
    PtrTo<JsNameAndName> _names;
};

struct Meta {

private:
    MetaNames _names;
    PtrTo<ModuleMeta> _topLevelModule;
    UInt8 _flags;
    UInt8 _introduced_in_host;
    UInt8 _introduced_in_extensions;

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
        return (this->hasName()) ? this->_names._names->jsName.valuePtr() : this->_names._name.valuePtr();
    }

    const char* name() const {
        return (this->hasName()) ? this->_names._names->name.valuePtr() : this->jsName();
    }

    /**
     * \brief The version number in which this entity was introduced.
     */
    UInt8 introducedInHost() const {
        return this->_introduced_in_host;
    }

    UInt8 introducedInExtensions() const {
        return this->_introduced_in_extensions;
    }

    UInt8 introducedIn() const;

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

    TypeEncodingsList<ArrayCount>* fieldsEncodings() const {
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

    TypeEncodingsList<ArrayCount>* encodings() const {
        return _encoding.valuePtr();
    }

    bool ownsReturnedCocoaObject() const {
        return this->flag(MetaFlags::FunctionOwnsReturnedCocoaObject);
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
    TypeEncoding* encoding() const {
        return _encoding.valuePtr();
    }
};

struct MemberMeta : Meta {
};

struct MethodMeta : MemberMeta {

private:
    PtrTo<TypeEncodingsList<ArrayCount>> _encodings;

public:
    bool isVariadic() const {
        return this->flag(MetaFlags::MethodIsVariadic);
    }

    bool isVariadicNullTerminated() const {
        return this->flag(MetaFlags::MethodIsNullTerminatedVariadic);
    }

    SEL selector() const {
        return sel_registerName(this->selectorAsString());
    }

    // just a more convenient way to get the selector of method
    const char* selectorAsString() const {
        return this->name();
    }

    TypeEncodingsList<ArrayCount>* encodings() const {
        return this->_encodings.valuePtr();
    }

    bool ownsReturnedCocoaObject() const {
        return this->flag(MetaFlags::MethodOwnsReturnedCocoaObject);
    }
};

struct PropertyMeta : MemberMeta {
    PtrTo<MethodMeta> _method1;
    PtrTo<MethodMeta> _method2;

public:
    bool hasGetter() const {
        return this->flag(MetaFlags::PropertyHasGetter);
    }

    bool hasSetter() const {
        return this->flag(MetaFlags::PropertyHasSetter);
    }

    MethodMeta* getter() const {
        return this->hasGetter() ? _method1.valuePtr() : nullptr;
    }

    MethodMeta* setter() const {
        return (this->hasSetter()) ? (this->hasGetter() ? _method2.valuePtr() : _method1.valuePtr()) : nullptr;
    }
};

struct BaseClassMeta : Meta {

    PtrTo<ArrayOfPtrTo<MethodMeta>> _instanceMethods;
    PtrTo<ArrayOfPtrTo<MethodMeta>> _staticMethods;
    PtrTo<ArrayOfPtrTo<PropertyMeta>> _properties;
    PtrTo<Array<String>> _protocols;
    int16_t _initializersStartIndex;

    MemberMeta* member(const char* identifier, size_t length, MemberType type, bool includeProtocols = true, bool onlyIfAvailable = true) const;

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

    /// static methods
    MethodMeta* staticMethod(const char* identifier, bool includeProtocols = true) const {
        return (MethodMeta*)this->member(identifier, MemberType::StaticMethod, includeProtocols);
    }

    MethodMeta* staticMethod(StringImpl* identifier, bool includeProtocols = true) const {
        return (MethodMeta*)this->member(identifier, MemberType::StaticMethod, includeProtocols);
    }

    /// properties
    PropertyMeta* property(const char* identifier, bool includeProtocols = true) const {
        return (PropertyMeta*)this->member(identifier, MemberType::Property, includeProtocols);
    }

    PropertyMeta* property(StringImpl* identifier, bool includeProtocols = true) const {
        return (PropertyMeta*)this->member(identifier, MemberType::Property, includeProtocols);
    }

    /// vectors
    std::vector<PropertyMeta*> properties() const {
        std::vector<PropertyMeta*> properties;
        return this->properties(properties);
    }

    std::vector<PropertyMeta*> propertiesWithProtocols() const {
        std::vector<PropertyMeta*> properties;
        return this->propertiesWithProtocols(properties);
    }

    std::vector<PropertyMeta*> properties(std::vector<PropertyMeta*>& container) const {
        for (Array<PtrTo<PropertyMeta>>::iterator it = this->_properties->begin(); it != this->_properties->end(); it++) {
            container.push_back((*it).valuePtr());
        }
        return container;
    }

    std::vector<PropertyMeta*> propertiesWithProtocols(std::vector<PropertyMeta*>& container) const;

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
        if (!_baseName.isNull()) {
            const Meta* baseMeta = MetaFile::instance()->globalTable()->findMeta(this->baseName());
            return baseMeta->type() == MetaType::Interface ? (InterfaceMeta*)baseMeta : nullptr;
        }
        return nullptr;
    }
};

#pragma pack(pop)
}

#endif /* defined(__NativeScript__Metadata__) */
