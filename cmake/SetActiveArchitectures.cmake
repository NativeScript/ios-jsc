macro(SetActiveArchitectures _target)
    set_target_properties(${_target} PROPERTIES
        XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH "NO"
        XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH[variant=Debug] "YES"
    )
endmacro()
