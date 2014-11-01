#!/bin/sh

printenv ANDROID_NDK_ROOT > /dev/null || { echo please export ANDROID_NDK_ROOT=root_dir_of_your_android_ndk; exit 1; }


SYS_ROOT=`ls -d $ANDROID_NDK_ROOT/platforms/android-*/arch-arm | tail -n 1` || exit 1
TOOL_CHAIN_DIR=`ls -d $ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-[4-5].*/prebuilt/* | tail -n 1` || exit 1
CC="$TOOL_CHAIN_DIR/bin/arm-linux-androideabi-g++ --sysroot=$SYS_ROOT"

#STL_ROOT=`ls -d $ANDROID_NDK_ROOT/sources/cxx-stl/gnu-libstdc++/[4-5].* | tail -n 1` || exit 1
#CC="$CC -I$STL_ROOT/include -I $STL_ROOT/libs/armeabi/include"

CC="$CC -O3"
CC="$CC -fmax-errors=5"
CC="$CC -fno-rtti -fno-exceptions"

mkdir bin 2>/dev/null
rm -f *.so

TARGET_DIR=../../../bin/android

v=220
echo ""
echo ---------------android $v --------------------
echo ---------------make sc-$v --------------------
$CC -DANDROID_VER=$v -fPIC -shared get-raw-image.cpp -o $TARGET_DIR/sc-$v || exit 1

echo ---------------make sc-$v test launcher --------------------
$CC -DANDROID_VER=$v -DMAKE_TEST=1 get-raw-image.cpp -o bin/sc-$v -Xlinker -rpath=/system/lib || exit 1

for v in 400 420; do
    echo ""
    echo ---------------android $v --------------------
	for f in libgui libbinder libutils; do
		echo ---------------make $f.so --------------------
		$CC -DANDROID_VER=$v -fPIC -shared $f.cpp -o $f.so || exit 1
	done

	echo ---------------make sc-$v --------------------
	$CC -DANDROID_VER=$v -fPIC -shared get-raw-image.cpp *.so -o $TARGET_DIR/sc-$v -Xlinker -rpath=/system/lib || exit 1

	echo ---------------make sc-$v test launcher --------------------
	$CC -DANDROID_VER=$v -DMAKE_TEST=1 get-raw-image.cpp *.so -o bin/sc-$v -Xlinker -rpath=/system/lib || exit 1

	rm -f *.so
done

echo ""; echo ok; echo ""
