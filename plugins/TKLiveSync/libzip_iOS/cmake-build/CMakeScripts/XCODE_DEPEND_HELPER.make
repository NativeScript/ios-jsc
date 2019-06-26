# DO NOT EDIT
# This makefile makes sure all linkable targets are
# up-to-date with anything they link to
default:
	echo "Do not invoke directly"

# Rules to remove targets that are older than anything to which they
# link.  This forces Xcode to relink the targets from scratch.  It
# does not seem to check these dependencies itself.
PostBuild.add_from_filep.Debug:
PostBuild.zip.Debug: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/add_from_filep
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/add_from_filep:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/add_from_filep


PostBuild.can_clone_file.Debug:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/can_clone_file:
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/can_clone_file


PostBuild.fopen_unchanged.Debug:
PostBuild.zip.Debug: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/fopen_unchanged
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/fopen_unchanged:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/fopen_unchanged


PostBuild.fread.Debug:
PostBuild.zip.Debug: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/fread
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/fread:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/fread


PostBuild.fseek.Debug:
PostBuild.zip.Debug: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/fseek
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/fseek:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/fseek


PostBuild.hole.Debug:
PostBuild.zip.Debug: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/hole
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/hole:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/hole


PostBuild.in-memory.Debug:
PostBuild.zip.Debug: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/examples/Debug/in-memory
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/examples/Debug/in-memory:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/examples/Debug/in-memory


PostBuild.nonrandomopen.Debug:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/libnonrandomopen.so:
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/libnonrandomopen.so


PostBuild.nonrandomopentest.Debug:
PostBuild.zip.Debug: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/nonrandomopentest
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/nonrandomopentest:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/nonrandomopentest


PostBuild.tryopen.Debug:
PostBuild.zip.Debug: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/tryopen
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/tryopen:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/tryopen


PostBuild.zip.Debug:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a:
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a


PostBuild.zipcmp.Debug:
PostBuild.zip.Debug: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Debug/zipcmp
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Debug/zipcmp:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Debug/zipcmp


PostBuild.zipmerge.Debug:
PostBuild.zip.Debug: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Debug/zipmerge
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Debug/zipmerge:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Debug/zipmerge


PostBuild.ziptool.Debug:
PostBuild.zip.Debug: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Debug/ziptool
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Debug/ziptool:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Debug/ziptool


PostBuild.ziptool_regress.Debug:
PostBuild.zip.Debug: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/ziptool_regress
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/ziptool_regress:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Debug/ziptool_regress


PostBuild.add_from_filep.Release:
PostBuild.zip.Release: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/add_from_filep
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/add_from_filep:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/add_from_filep


PostBuild.can_clone_file.Release:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/can_clone_file:
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/can_clone_file


PostBuild.fopen_unchanged.Release:
PostBuild.zip.Release: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/fopen_unchanged
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/fopen_unchanged:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/fopen_unchanged


PostBuild.fread.Release:
PostBuild.zip.Release: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/fread
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/fread:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/fread


PostBuild.fseek.Release:
PostBuild.zip.Release: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/fseek
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/fseek:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/fseek


PostBuild.hole.Release:
PostBuild.zip.Release: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/hole
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/hole:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/hole


PostBuild.in-memory.Release:
PostBuild.zip.Release: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/examples/Release/in-memory
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/examples/Release/in-memory:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/examples/Release/in-memory


PostBuild.nonrandomopen.Release:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/libnonrandomopen.so:
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/libnonrandomopen.so


PostBuild.nonrandomopentest.Release:
PostBuild.zip.Release: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/nonrandomopentest
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/nonrandomopentest:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/nonrandomopentest


PostBuild.tryopen.Release:
PostBuild.zip.Release: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/tryopen
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/tryopen:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/tryopen


PostBuild.zip.Release:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a:
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a


PostBuild.zipcmp.Release:
PostBuild.zip.Release: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Release/zipcmp
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Release/zipcmp:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Release/zipcmp


PostBuild.zipmerge.Release:
PostBuild.zip.Release: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Release/zipmerge
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Release/zipmerge:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Release/zipmerge


PostBuild.ziptool.Release:
PostBuild.zip.Release: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Release/ziptool
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Release/ziptool:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/Release/ziptool


PostBuild.ziptool_regress.Release:
PostBuild.zip.Release: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/ziptool_regress
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/ziptool_regress:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/Release/ziptool_regress


PostBuild.add_from_filep.MinSizeRel:
PostBuild.zip.MinSizeRel: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/add_from_filep
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/add_from_filep:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/add_from_filep


PostBuild.can_clone_file.MinSizeRel:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/can_clone_file:
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/can_clone_file


PostBuild.fopen_unchanged.MinSizeRel:
PostBuild.zip.MinSizeRel: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/fopen_unchanged
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/fopen_unchanged:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/fopen_unchanged


PostBuild.fread.MinSizeRel:
PostBuild.zip.MinSizeRel: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/fread
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/fread:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/fread


PostBuild.fseek.MinSizeRel:
PostBuild.zip.MinSizeRel: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/fseek
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/fseek:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/fseek


PostBuild.hole.MinSizeRel:
PostBuild.zip.MinSizeRel: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/hole
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/hole:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/hole


PostBuild.in-memory.MinSizeRel:
PostBuild.zip.MinSizeRel: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/examples/MinSizeRel/in-memory
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/examples/MinSizeRel/in-memory:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/examples/MinSizeRel/in-memory


PostBuild.nonrandomopen.MinSizeRel:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/libnonrandomopen.so:
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/libnonrandomopen.so


PostBuild.nonrandomopentest.MinSizeRel:
PostBuild.zip.MinSizeRel: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/nonrandomopentest
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/nonrandomopentest:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/nonrandomopentest


PostBuild.tryopen.MinSizeRel:
PostBuild.zip.MinSizeRel: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/tryopen
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/tryopen:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/tryopen


PostBuild.zip.MinSizeRel:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a:
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a


PostBuild.zipcmp.MinSizeRel:
PostBuild.zip.MinSizeRel: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/MinSizeRel/zipcmp
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/MinSizeRel/zipcmp:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/MinSizeRel/zipcmp


PostBuild.zipmerge.MinSizeRel:
PostBuild.zip.MinSizeRel: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/MinSizeRel/zipmerge
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/MinSizeRel/zipmerge:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/MinSizeRel/zipmerge


PostBuild.ziptool.MinSizeRel:
PostBuild.zip.MinSizeRel: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/MinSizeRel/ziptool
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/MinSizeRel/ziptool:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/MinSizeRel/ziptool


PostBuild.ziptool_regress.MinSizeRel:
PostBuild.zip.MinSizeRel: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/ziptool_regress
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/ziptool_regress:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/MinSizeRel/ziptool_regress


PostBuild.add_from_filep.RelWithDebInfo:
PostBuild.zip.RelWithDebInfo: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/add_from_filep
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/add_from_filep:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/add_from_filep


PostBuild.can_clone_file.RelWithDebInfo:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/can_clone_file:
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/can_clone_file


PostBuild.fopen_unchanged.RelWithDebInfo:
PostBuild.zip.RelWithDebInfo: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/fopen_unchanged
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/fopen_unchanged:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/fopen_unchanged


PostBuild.fread.RelWithDebInfo:
PostBuild.zip.RelWithDebInfo: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/fread
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/fread:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/fread


PostBuild.fseek.RelWithDebInfo:
PostBuild.zip.RelWithDebInfo: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/fseek
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/fseek:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/fseek


PostBuild.hole.RelWithDebInfo:
PostBuild.zip.RelWithDebInfo: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/hole
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/hole:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/hole


PostBuild.in-memory.RelWithDebInfo:
PostBuild.zip.RelWithDebInfo: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/examples/RelWithDebInfo/in-memory
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/examples/RelWithDebInfo/in-memory:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/examples/RelWithDebInfo/in-memory


PostBuild.nonrandomopen.RelWithDebInfo:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/libnonrandomopen.so:
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/libnonrandomopen.so


PostBuild.nonrandomopentest.RelWithDebInfo:
PostBuild.zip.RelWithDebInfo: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/nonrandomopentest
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/nonrandomopentest:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/nonrandomopentest


PostBuild.tryopen.RelWithDebInfo:
PostBuild.zip.RelWithDebInfo: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/tryopen
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/tryopen:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/tryopen


PostBuild.zip.RelWithDebInfo:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a:
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a


PostBuild.zipcmp.RelWithDebInfo:
PostBuild.zip.RelWithDebInfo: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/RelWithDebInfo/zipcmp
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/RelWithDebInfo/zipcmp:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/RelWithDebInfo/zipcmp


PostBuild.zipmerge.RelWithDebInfo:
PostBuild.zip.RelWithDebInfo: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/RelWithDebInfo/zipmerge
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/RelWithDebInfo/zipmerge:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/RelWithDebInfo/zipmerge


PostBuild.ziptool.RelWithDebInfo:
PostBuild.zip.RelWithDebInfo: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/RelWithDebInfo/ziptool
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/RelWithDebInfo/ziptool:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/src/RelWithDebInfo/ziptool


PostBuild.ziptool_regress.RelWithDebInfo:
PostBuild.zip.RelWithDebInfo: /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/ziptool_regress
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/ziptool_regress:\
	/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a\
	/usr/lib/libz.dylib\
	/usr/lib/libbz2.dylib
	/bin/rm -f /Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/regress/RelWithDebInfo/ziptool_regress




# For each target create a dummy ruleso the target does not have to exist
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Debug/libzip.a:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/MinSizeRel/libzip.a:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/RelWithDebInfo/libzip.a:
/Users/bektchiev/Downloads/libzip-1.5.2/cmake-build/lib/Release/libzip.a:
/usr/lib/libbz2.dylib:
/usr/lib/libz.dylib:
