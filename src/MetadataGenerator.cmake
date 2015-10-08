include(ExternalProject)
ExternalProject_Add(MetadataGenerator
    SOURCE_DIR "${CMAKE_SOURCE_DIR}/src/metadata-generator"
    CONFIGURE_COMMAND env -i "${CMAKE_COMMAND}"
        -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/metadataGenerator
        -DCMAKE_BUILD_TYPE=$<CONFIG>
        "${CMAKE_SOURCE_DIR}/src/metadata-generator"
    BUILD_COMMAND env -i "${CMAKE_COMMAND}"
        --build .
        --target install
        --use-stderr
    INSTALL_COMMAND ""
)

get_property(MetadataGenerator_BINARY_DIR TARGET MetadataGenerator PROPERTY _EP_BINARY_DIR)
