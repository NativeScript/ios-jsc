set -ex
cmake -DBUILD_SHARED_LIBS=1 -GXcode . -Bcmake-build

# Workaround for https://cmake.org/pipermail/cmake/2015-April/060484.html
sed -i bak -e 's/Versions\/A\///g' cmake-build/NativeScript.xcodeproj/project.pbxproj
# Manually switch to Modern build system because CMake currently doesn't fully support it (luckily our build works with it!)
# see https://gitlab.kitware.com/cmake/cmake/issues/18088
sed -i bak -e 's/>BuildSystemType</>BuildSystemType_REVERTED</g' cmake-build/NativeScript.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings
