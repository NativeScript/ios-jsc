macro(SetPrecompiledHeader _target _header)
        set_target_properties(${_target} PROPERTIES
            XCODE_ATTRIBUTE_GCC_PREFIX_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/${_header}"
            XCODE_ATTRIBUTE_GCC_PRECOMPILE_PREFIX_HEADER "${NATIVESCRIPT_PRECOMPILE_PREFIX_HEADER}"
        )
endmacro()
