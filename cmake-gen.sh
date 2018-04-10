set -ex
mkdir -p cmake-build
cd cmake-build
cmake -DBUILD_SHARED_LIBS=1 -GXcode ..

# Workaround for https://cmake.org/pipermail/cmake/2015-April/060484.html
sed -i bak -e 's/Versions\/A\///g' NativeScript.xcodeproj/project.pbxproj
