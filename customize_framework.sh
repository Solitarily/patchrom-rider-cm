#!/bin/bash
# $1: dir for miui
# $2: dir for original

APKTOOL="$PORT_ROOT/tools/apktool --quiet"
BUILD_OUT=out

SEP_FRAME="framework_ext.jar.out"

if [ $2 = "$BUILD_OUT/framework" ]
then
    # remove all files at out/framework those exist in framework_ext.jar.out
    for file2 in `find framework_ext.jar.out -name *.smali`; do
            file=${file2/framework_ext.jar.out/$BUILD_OUT\/framework}
            echo "rm file: $file"
            rm -rf "$file"
    done

    # remove all files at out/framework those exist in telephony-common.jar.out
    for file4 in `find telephony-common.jar.out -name *.smali`; do
            file3=${file4/telephony-common.jar.out/$BUILD_OUT\/framework}
            echo "rm file: $file3"
            rm -rf "$file3"
    done

	#rm -rf "$BUILD_OUT/framework/smali/com/google/android/mms"

    # move some smali to create a separate $SEP_FRAME.jar
    # including: smali/miui smali/android/widget
	mkdir -p "$BUILD_OUT/$SEP_FRAME/smali"
    #rm -rf $BUILD_OUT/$SEP_FRAME/smali/miui
	rm -rf "$BUILD_OUT/$SEP_FRAME/smali/android/"
	mkdir -p "$BUILD_OUT/$SEP_FRAME/smali/android"
        #overlay
        cp -f overlay/Editor/* $BUILD_OUT/framework/smali/android/widget
    mv "$BUILD_OUT/framework/smali/android/widget" "$BUILD_OUT/$SEP_FRAME/smali/android/"
	#mv "$BUILD_OUT/framework/smali/miui" "$BUILD_OUT/$SEP_FRAME/smali"
fi

if [ $2 = "$BUILD_OUT/framework_ext" ]
then
    # apply framework_ext.part on framework_ext.jar.out
    cp -f other/framework_ext.part out/
    cd out
    $PORT_ROOT/tools/git.apply framework_ext.part
    cd ..
    for file3 in `find $2 -name *.rej`
    do
	echo "Fatal error: framework_ext patch fail"
        exit 1
    done

    # remove all files at out/framework_ext those exist in framework.jar.out
    for file2 in `find framework.jar.out -name *.smali`; do
            file=${file2/framework.jar.out/$BUILD_OUT\/framework_ext}
            echo "rm file: $file"
            rm -rf "$file"
    done

	#cp -rf "$BUILD_OUT/framework_miui/smali/com/google/android/mms" "$BUILD_OUT/framework_ext/smali/com/google/android"
	mv "$BUILD_OUT/$SEP_FRAME/smali/android/widget/"  "$BUILD_OUT/framework_ext/smali/android/widget"
	#mv "$BUILD_OUT/$SEP_FRAME/smali/miui/"  "$BUILD_OUT/framework_ext/smali/miui"
	rm -rf $BUILD_OUT/$SEP_FRAME
fi
