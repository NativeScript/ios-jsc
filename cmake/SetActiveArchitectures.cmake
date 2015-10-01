macro(SetActiveArchitectures _target)
    set_target_properties(${_target} PROPERTIES XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH "NO")

    if(${BUILD_ONLY_ACTIVE_ARCH})
        set_target_properties(${_target} PROPERTIES XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH[variant=Debug] "YES")
    endif()
endmacro()
