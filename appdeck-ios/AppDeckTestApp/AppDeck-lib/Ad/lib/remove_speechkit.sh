
rm -rf patch
mkdir patch
cp libMMSDK_5.1.1.a patch/
cd patch

ar -t libMMSDK_5.1.1-armv7.a
lipo -thin armv7 libMMSDK_5.1.1.a -output libMMSDK_5.1.1-armv7.a
lipo -thin armv7s libMMSDK_5.1.1.a -output libMMSDK_5.1.1-armv7s.a
lipo -thin i386 libMMSDK_5.1.1.a -output libMMSDK_5.1.1-i386.a

mkdir libMMSDK_5.1.1-armv7
cd libMMSDK_5.1.1-armv7
ar -x ../libMMSDK_5.1.1-armv7.a
ld -r NVASpeechkit.o -o NEW_NVASpeechkit.o -alias '_AUDIO_LEVEL_MAX' '_AUDIO_LEVEL_MXX' -unexported_symbol '_AUDIO_LEVEL_MAX'
mv NEW_NVASpeechkit.o NVASpeechkit.o
libtool -static *.o  -o ../libMMSDK_5.1.1-armv7.a
cd ..

mkdir libMMSDK_5.1.1-armv7s
cd libMMSDK_5.1.1-armv7s
ar -x ../libMMSDK_5.1.1-armv7s.a
ld -r NVASpeechkit.o -o NEW_NVASpeechkit.o -alias '_AUDIO_LEVEL_MAX' '_AUDIO_LEVEL_MXX' -unexported_symbol '_AUDIO_LEVEL_MAX'
mv NEW_NVASpeechkit.o NVASpeechkit.o
libtool -static *.o  -o ../libMMSDK_5.1.1-armv7s.a
cd ..

mkdir libMMSDK_5.1.1-i386
cd libMMSDK_5.1.1-i386
ar -x ../libMMSDK_5.1.1-i386.a
ld -r NVASpeechkit.o -o NEW_NVASpeechkit.o -alias '_AUDIO_LEVEL_MAX' '_AUDIO_LEVEL_MXX' -unexported_symbol '_AUDIO_LEVEL_MAX'
mv NEW_NVASpeechkit.o NVASpeechkit.o
libtool -static *.o  -o ../libMMSDK_5.1.1-i386.a
cd ..

lipo -thin armv7 libWSLibrary.a -output libWSLibrary-armv7.a
lipo -thin armv7s libWSLibrary.a -output libWSLibrary-armv7s.a
lipo -thin i386 libWSLibrary.a -output libWSLibrary-i386.a

mkdir libMMSDK_5.1.1-armv7
cd libMMSDK_5.1.1-armv7
ar -x ../libMMSDK_5.1.1-armv7.a
ld -r NVASpeechkit.o -o NEW_NVASpeechkit.o -alias '_AUDIO_LEVEL_MAX' '_AUDIO_LEVEL_MXX' -unexported_symbol '_AUDIO_LEVEL_MAX'
mv NEW_NVASpeechkit.o NVASpeechkit.o
libtool -static *.o  -o ../libMMSDK_5.1.1-armv7.a
cd ..

mkdir libMMSDK_5.1.1-armv7s
cd libMMSDK_5.1.1-armv7s
ar -x ../libMMSDK_5.1.1-armv7s.a
ld -r NVASpeechkit.o -o NEW_NVASpeechkit.o -alias '_AUDIO_LEVEL_MAX' '_AUDIO_LEVEL_MXX' -unexported_symbol '_AUDIO_LEVEL_MAX'
mv NEW_NVASpeechkit.o NVASpeechkit.o
libtool -static *.o  -o ../libMMSDK_5.1.1-armv7s.a
cd ..

mkdir libMMSDK_5.1.1-i386
cd libMMSDK_5.1.1-i386
ar -x ../libMMSDK_5.1.1-i386.a
ld -r NVASpeechkit.o -o NEW_NVASpeechkit.o -alias '_AUDIO_LEVEL_MAX' '_AUDIO_LEVEL_MXX' -unexported_symbol '_AUDIO_LEVEL_MAX'
mv NEW_NVASpeechkit.o NVASpeechkit.o
libtool -static *.o  -o ../libMMSDK_5.1.1-i386.a
cd ..

lipo -create libMMSDK_5.1.1-armv7.a libMMSDK_5.1.1-armv7s.a libMMSDK_5.1.1-i386.a libWSLibrary-armv7.a-o libMMSDK_5.1.1.a

mkdir armv7
cd armv7
ar -x ../libMMSDK_5.1.1-armv7.a
ar -x ../libWSLibrary-armv7.a
libtool -static *.o  -o ../armv7.a
cd ..
mkdir armv7s
cd armv7s
ar -x ../libMMSDK_5.1.1-armv7s.a
ar -x ../libWSLibrary-armv7s.a
libtool -static *.o  -o ../armv7s.a
cd ..

mkdir i386
cd i386
ar -x ../libMMSDK_5.1.1-i386.a
ar -x ../libWSLibrary-i386.a
libtool -static *.o  -o ../i386.a
cd ..


lipo -create armv7.a armv7s.a i386.a libWSLibrary-armv7.a-o libAdSDK.a