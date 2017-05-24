# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /Applications/Android/sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

-dontobfuscate

#appdeck plugin
#-keep class * implements com.mobideck.appdeck.plugin.Plugin
-keep class com.mobideck.appdeck.** {*;}
-keep class com.mobideck.appdeck.plugin.* {*;}

# crashlytics
-keep class com.crashlytics.** { *; }
-keep class com.crashlytics.android.**
# we want fabric crash report with line number
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
-printmapping out.map
-keep public class * extends java.lang.Exception

-dontwarn com.google.common.**

-dontwarn okhttp3.**
-dontwarn okio.**

# android support
-keep class !android.support.v7.internal.view.menu.*MenuBuilder*, android.support.v7.** { *; }
-keep interface android.support.v7.** { *; }

# support design
-dontwarn android.support.design.**
-keep class android.support.design.** { *; }
-keep interface android.support.design.** { *; }
-keep public class android.support.design.R$* { *; }

# Flurry
#-keep class com.flurry.** { *; }
#-dontwarn com.flurry.**
#-keepattributes *Annotation*,EnclosingMethod,Signature
#-keepclasseswithmembers class * {
#    public <init>(android.content.Context, android.util.AttributeSet, int);
#}

# Google Play Services library
-keep class * extends java.util.ListResourceBundle {
    protected Object[][] getContents();
}
-keep public class com.google.android.gms.common.internal.safeparcel.SafeParcelable {
    public static final *** NULL;
}
-keepnames @com.google.android.gms.common.annotation.KeepName class *
-keepclassmembernames class * {
    @com.google.android.gms.common.annotation.KeepName *;
}
-keepnames class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# SmartAdServer
-keepclassmembers class com.smartadserver.android.library.** {
@android.webkit.JavascriptInterface <methods>;
}

# Start App
-keep class com.startapp.** {
      *;
}
-dontwarn android.webkit.JavascriptInterface
-dontwarn com.startapp.**

# Mobile Core
-keep class com.ironsource.mobilcore.**{ *; }

# Twitter
-dontwarn com.squareup.okhttp.**
-dontwarn com.google.appengine.api.urlfetch.**
-dontwarn rx.**
-dontwarn retrofit.**
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.squareup.okhttp.** { *; }
-keep interface com.squareup.okhttp.** { *; }
-keep class retrofit.** { *; }
-keepclasseswithmembers class * {
    @retrofit.http.* <methods>;
}

# facebook
-dontwarn org.apache.http.**

# smaato
-dontwarn com.unity3d.player.**
-keep public class com.smaato.soma.internal.connector.OrmmaBridge {
    public *;
}
-keepattributes *Annotation*

# smart ad server
-dontwarn com.millennialmedia.**

# aerserv
-keep class com.aerserv.** { *; }
-keepclassmembers class com.aerserv.** { *; }
-dontwarn com.aerserv.sdk.adapter.**

# InMobi
-keep class com.inmobi.** { *; }
-dontwarn com.inmobi.**

# MMedia
-keepclassmembers class com.millennialmedia** {
    public *;
}
-keep class com.millennialmedia**

# Presage
-dontwarn android.net.*
-dontwarn android.provider.Browser

# remove log
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

-dontwarn org.chromium.base.multidex.**

# Presage
-keepattributes Signature
-keep class sun.misc.Unsafe { *; }

-keep class shared_presage.** { *; }
-keep class io.presage.** { *; }
-keepclassmembers class io.presage.** {
 *;
}

-keepattributes *Annotation*
-keepattributes JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# bug in proguard
# http://sourceforge.net/p/proguard/bugs/573/
# java -jar /Applications/Android/sdk/tools/proguard/lib/proguard.jar
# ProGuard, version 4.7
-optimizations !class/unboxing/enum,!code/allocation/variable

-dontwarn com.nuance.**

# there were 16 classes trying to access annotations using reflection. You should consider keeping the annotation attributes (using '-keepattributes *Annotation*'). (http://proguard.sourceforge.net/manual/troubleshooting.html#attributes)
#-keepattributes *Annotation*
# there were 27 classes trying to access generic signatures using reflection. You should consider keeping the signature attributes (using '-keepattributes Signature'). (http://proguard.sourceforge.net/manual/troubleshooting.html#attributes)
#-keepattributes Signature
# Note: there were 3 classes trying to access enclosing classes using reflection. You should consider keeping the inner classes attributes (using '-keepattributes InnerClasses'). (http://proguard.sourceforge.net/manual/troubleshooting.html#attributes)
#-keepattributes InnerClasses
# Note: there were 2 classes trying to access enclosing methods using reflection. You should consider keeping the enclosing method attributes (using '-keepattributes InnerClasses,EnclosingMethod'). (http://proguard.sourceforge.net/manual/troubleshooting.html#attributes)
#-keepattributes InnerClasses,EnclosingMethod
# Note: there were 50 unresolved dynamic references to classes or interfaces. You should check if you need to specify additional program jars. (http://proguard.sourceforge.net/manual/troubleshooting.html#dynamicalclass)
