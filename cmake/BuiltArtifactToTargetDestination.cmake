# Copy target's final build product from the built location to where CMake expects to find it.
# When invoking `xcodebuild archive` it is different and we needed to explicitly perform a
# redundant `xcodebuild build` command beforehand.
macro(CopyBuiltArtifactToTargetDestinationIfDifferent _target)
    PostBuildCopyIfDestDifferentThanSrc(${_target} $(TARGET_BUILD_DIR) $<TARGET_FILE:${_target}>)
endmacro()


macro(PostBuildCopyIfDestDifferentThanSrc _target _srcDir _dest)
    add_custom_command(
        TARGET
        ${_target}
        POST_BUILD COMMAND
        if [ \"`dirname \\\"${_dest}\\\"`\" != \"${_srcDir}\" ]
        \; then
            ${CMAKE_COMMAND} -E make_directory
            `dirname ${_dest}`
            &&
            ${CMAKE_COMMAND} -E copy
            ${_srcDir}/`basename ${_dest}`
            ${_dest}
        \; fi
    )
endmacro()
