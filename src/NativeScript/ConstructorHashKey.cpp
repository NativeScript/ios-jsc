#include "ConstructorHashKey.h"

namespace NativeScript {

const ConstructorHashKey ConstructorHashKey::EmptyValue{ Metadata::KnownUnknownClassPair::EmptyValue, Metadata::ProtocolMetaVector() };
const ConstructorHashKey ConstructorHashKey::DeletedValue{ Metadata::KnownUnknownClassPair::DeletedValue, Metadata::ProtocolMetaVector() };

} // namespace NativeScript
