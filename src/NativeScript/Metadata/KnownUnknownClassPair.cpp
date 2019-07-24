#include "KnownUnknownClassPair.h"

namespace Metadata {

const KnownUnknownClassPair& KnownUnknownClassPair::EmptyValue() {
    static const KnownUnknownClassPair emptyValue;
    return emptyValue;
}
const KnownUnknownClassPair& KnownUnknownClassPair::DeletedValue() {
    static const KnownUnknownClassPair deletedValue((Class)-1, (Class)-1);
    return deletedValue;
}

} // namespace Metadata
