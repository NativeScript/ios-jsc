#include "KnownUnknownClassPair.h"

namespace Metadata {

const KnownUnknownClassPair KnownUnknownClassPair::EmptyValue = { nullptr, nullptr };
const KnownUnknownClassPair KnownUnknownClassPair::DeletedValue = { (Class)-1, (Class)-1 };

} // namespace Metadata
