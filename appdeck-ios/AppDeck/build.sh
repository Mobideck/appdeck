#!/bin/sh

XCODEBUILD_PATH=/Applications/Xcode.app/Contents/Developer/usr/bin
XCODEBUILD=$XCODEBUILD_PATH/xcodebuild

$XCODEBUILD -project AppDeck.xcodeproj -target "AppDeck" -sdk "iphonesimulator" -configuration "Release" clean build
$XCODEBUILD -project AppDeck.xcodeproj -target "AppDeck" -sdk "iphoneos" -configuration "Release" clean build

cp -r build/Release-iphoneos/include/AppDeck build
lipo -create -output "build/AppDeck/AppDeck.a" "build/Release-iphoneos/libAppDeck.a" "build/Release-iphonesimulator/libAppDeck.a"
