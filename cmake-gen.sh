set -ex
cmake -DBUILD_SHARED_LIBS=1 -GXcode . ---build cmake-build

# Workaround for https://cmake.org/pipermail/cmake/2015-April/060484.html
sed -i bak -e 's/Versions\/A\///g' cmake-build/NativeScript.xcodeproj/project.pbxproj
