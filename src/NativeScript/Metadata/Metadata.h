//
//  Metadata.h
//  NativeScript
//
//  Created by Ivan Buhov on 8/1/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__Metadata__
#define __NativeScript__Metadata__

#include <stack>
#include <string>
#include <type_traits>
#include <vector>

namespace Metadata {

static const int MetaTypeMask = 0b00000111;

// Bit indices in flags section
enum MetaFlags {
    HasName = 7,
    // IsIosAppExtensionAvailable = 6, the flag exists in metadata generator but we never use it in the runtime
    FunctionReturnsUnmanaged = 3,
    FunctionIsVariadic = 5,
    FunctionOwnsReturnedCocoaObject = 4,
    MethodIsInitializer = 1,
    MethodIsVariadic = 2,
    MethodIsNullTerminatedVariadic = 3,
    MethodOwnsReturnedCocoaObject = 4,
    MethodHasErrorOutParameter = 5,
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

    static MetaFile* setInstance(void* metadataPtr);

    const GlobalTable* globalTable() const {
        return &this->_globalTable;
    }

    const ModuleTable* topLevelModulesTable() const {
        const GlobalTable* gt = this->globalTable();
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
        return PtrTo<T>{.offset = this->offset + value * sizeof(T) };
    }
    PtrTo<T> addBytes(int bytes) const {
        return PtrTo<T>{.offset = this->offset + bytes };
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
    struct DeclarationReferenceDetails {
        String name;
    } declarationReference;
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
        case BinaryTypeEncodingType::InterfaceDeclarationReference:
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
};

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
};

struct BaseClassMeta : Meta {

    PtrTo<ArrayOfPtrTo<MethodMeta>> instanceMethods;
    PtrTo<ArrayOfPtrTo<MethodMeta>> staticMethods;
    PtrTo<ArrayOfPtrTo<PropertyMeta>> instanceProps;
    PtrTo<ArrayOfPtrTo<PropertyMeta>> staticProps;
    PtrTo<Array<String>> protocols;
    int16_t initializersStartIndex;

    const MemberMeta* member(const char* identifier, size_t length, MemberType type, bool includeProtocols = true, bool onlyIfAvailable = true) const;

    const MemberMeta* member(StringImpl* identifier, MemberType type, bool includeProtocols = true) const {
        const char* identif = reinterpret_cast<const char*>(identifier->characters8());
        size_t length = (size_t)identifier->length();
        return this->member(identif, length, type, includeProtocols);
    }

    const MemberMeta* member(const char* identifier, MemberType type, bool includeProtocols = true) const {
        return this->member(identifier, strlen(identifier), type, includeProtocols);
    }

    /// instance methods
    const MethodMeta* instanceMethod(const char* identifier, bool includeProtocols = true) const {
        return reinterpret_cast<const MethodMeta*>(this->member(identifier, MemberType::InstanceMethod, includeProtocols));
    }

    const MethodMeta* instanceMethod(StringImpl* identifier, bool includeProtocols = true) const {
        return reinterpret_cast<const MethodMeta*>(this->member(identifier, MemberType::InstanceMethod, includeProtocols));
    }

    /// static methods
    const MethodMeta* staticMethod(const char* identifier, bool includeProtocols = true) const {
        return reinterpret_cast<const MethodMeta*>(this->member(identifier, MemberType::StaticMethod, includeProtocols));
    }

    const MethodMeta* staticMethod(StringImpl* identifier, bool includeProtocols = true) const {
        return reinterpret_cast<const MethodMeta*>(this->member(identifier, MemberType::StaticMethod, includeProtocols));
    }

    /// instance properties
    const PropertyMeta* instanceProperty(const char* identifier, bool includeProtocols = true) const {
        return reinterpret_cast<const PropertyMeta*>(this->member(identifier, MemberType::InstanceProperty, includeProtocols));
    }

    const PropertyMeta* instanceProperty(StringImpl* identifier, bool includeProtocols = true) const {
        return reinterpret_cast<const PropertyMeta*>(this->member(identifier, MemberType::InstanceProperty, includeProtocols));
    }

    /// static properties
    const PropertyMeta* staticProperty(const char* identifier, bool includeProtocols = true) const {
        return reinterpret_cast<const PropertyMeta*>(this->member(identifier, MemberType::StaticProperty, includeProtocols));
    }

    const PropertyMeta* staticProperty(StringImpl* identifier, bool includeProtocols = true) const {
        return reinterpret_cast<const PropertyMeta*>(this->member(identifier, MemberType::StaticProperty, includeProtocols));
    }

    /// vectors
    std::vector<const PropertyMeta*> instanceProperties() const {
        std::vector<const PropertyMeta*> properties;
        return this->instanceProperties(properties);
    }

    std::vector<const PropertyMeta*> instancePropertiesWithProtocols() const {
        std::vector<const PropertyMeta*> properties;
        return this->instancePropertiesWithProtocols(properties);
    }

    std::vector<const PropertyMeta*> instanceProperties(std::vector<const PropertyMeta*>& container) const {
        for (Array<PtrTo<PropertyMeta>>::iterator it = this->instanceProps->begin(); it != this->instanceProps->end(); it++) {
            container.push_back((*it).valuePtr());
        }
        return container;
    }

    std::vector<const PropertyMeta*> instancePropertiesWithProtocols(std::vector<const PropertyMeta*>& container) const;

    std::vector<const PropertyMeta*> staticProperties() const {
        std::vector<const PropertyMeta*> properties;
        return this->staticProperties(properties);
    }

    std::vector<const PropertyMeta*> staticPropertiesWithProtocols() const {
        std::vector<const PropertyMeta*> properties;
        return this->staticPropertiesWithProtocols(properties);
    }

    std::vector<const PropertyMeta*> staticProperties(std::vector<const PropertyMeta*>& container) const {
        for (Array<PtrTo<PropertyMeta>>::iterator it = this->staticProps->begin(); it != this->staticProps->end(); it++) {
            container.push_back((*it).valuePtr());
        }
        return container;
    }

    std::vector<const PropertyMeta*> staticPropertiesWithProtocols(std::vector<const PropertyMeta*>& container) const;

    std::vector<const MethodMeta*> initializers() const {
        std::vector<const MethodMeta*> initializers;
        return this->initializers(initializers);
    }

    std::vector<const MethodMeta*> initializersWithProtcols() const {
        std::vector<const MethodMeta*> initializers;
        return this->initializersWithProtcols(initializers);
    }

    std::vector<const MethodMeta*> initializers(std::vector<const MethodMeta*>& container) const;

    std::vector<const MethodMeta*> initializersWithProtcols(std::vector<const MethodMeta*>& container) const;
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
            const Meta* baseMeta = MetaFile::instance()->globalTable()->findMeta(this->baseName());
            return baseMeta->type() == MetaType::Interface ? reinterpret_cast<const InterfaceMeta*>(baseMeta) : nullptr;
        }
        return nullptr;
    }
};

#pragma pack(pop)
}

#endif /* defined(__NativeScript__Metadata__) */
