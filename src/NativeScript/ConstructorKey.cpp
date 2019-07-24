#include "ConstructorKey.h"

namespace NativeScript {

const ConstructorKey& ConstructorKey::EmptyValue() {
    static const ConstructorKey emptyValue;
    return emptyValue;
}

const ConstructorKey& ConstructorKey::DeletedValue() {
    static const ConstructorKey deletedValue(Metadata::KnownUnknownClassPair::DeletedValue());
    return deletedValue;
}

} // namespace NativeScript
