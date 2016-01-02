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

# crashlytics
-keep class com.crashlytics.** { *; }
-keep class com.crashlytics.android.**
#-keepattributes SourceFile,LineNumberTable *Annotation*
#-keep public class * extends java.lang.Exception

# netty
# Get rid of warnings about unreachable but unused classes referred to by Netty
-dontwarn org.jboss.**
-dontwarn org.xbill.**
-dontwarn org.apache.log4j.**
-dontwarn org.apache.commons.logging.**
-dontwarn sun.**
-dontwarn com.sun.**
-dontwarn javassist.**
-dontwarn gnu.io.**
-dontwarn com.barchart.**
-dontwarn com.jcraft.**
-dontwarn com.google.protobuf.**
-dontwarn org.eclipse.**
-dontwarn org.apache.tomcat.**
-dontwarn org.bouncycastle.**
-dontwarn java.nio.**
-dontwarn java.net.**
-dontwarn javax.net.**
-dontwarn android.app.Notification
# Needed by commons logging
-keep class org.apache.commons.logging.* {*;}
#Some Factory that seemed to be pruned
-keep class java.util.concurrent.atomic.AtomicReferenceFieldUpdater {*;}
-keep class java.util.concurrent.atomic.AtomicReferenceFieldUpdaterImpl{*;}
#Some important internal fields that where removed
-keep class org.jboss.netty.channel.DefaultChannelPipeline{volatile <fields>;}
#A Factory which has a static factory implementation selector which is pruned
-keep class org.jboss.netty.util.internal.QueueFactory{static <fields>;}
#Some fields whose names need to be maintained because they are accessed using inflection
-keepclassmembernames class org.jboss.netty.util.internal.**{*;}

# android support
-keep class !android.support.v7.internal.view.menu.*MenuBuilder*, android.support.v7.** { *; }
-keep interface android.support.v7.** { *; }

# support design
-dontwarn android.support.design.**
-keep class android.support.design.** { *; }
-keep interface android.support.design.** { *; }
-keep public class android.support.design.R$* { *; }

# Flurry
-keep class com.flurry.** { *; }
-dontwarn com.flurry.**
-keepattributes *Annotation*,EnclosingMethod,Signature
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

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

#If you are using the Google Mobile Ads SDK, add the following:
# Preserve GMS ads classes
-keep class com.google.android.gms.** { *;
}
-dontwarn com.google.android.gms.**

# If you are using the InMobi SDK, add the following:
# Preserve InMobi Ads classes
-keep class com.inmobi.** { *;
}
-dontwarn com.inmobi.**
# If you are using the Millennial Media SDK, add the following:
# Preserve Millennial Ads classes
-keep class com.millennialmedia.** { *;
}
-dontwarn com.millennialmedia.**

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

# crosswalk
-dontwarn android.view.*
-dontwarn android.webkit.*
-dontwarn android.app.assist.*

# remove log
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# bug in proguard
# http://sourceforge.net/p/proguard/bugs/573/
# java -jar /Applications/Android/sdk/tools/proguard/lib/proguard.jar
# ProGuard, version 4.7
-optimizations !class/unboxing/enum