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
# we want fabric crash report with line number
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
-printmapping out.map
-keep public class * extends java.lang.Exception

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

# remove slf4j
#-assumenosideeffects class * implements org.slf4j.Logger {
#    public *** trace(...);
#    public *** debug(...);
#    public *** info(...);
#    public *** warn(...);
#    public *** error(...);
#}

# bug in proguard
# http://sourceforge.net/p/proguard/bugs/573/
# java -jar /Applications/Android/sdk/tools/proguard/lib/proguard.jar
# ProGuard, version 4.7
-optimizations !class/unboxing/enum

-dontwarn com.nuance.**

# there were 16 classes trying to access annotations using reflection. You should consider keeping the annotation attributes (using '-keepattributes *Annotation*'). (http://proguard.sourceforge.net/manual/troubleshooting.html#attributes)
-keepattributes *Annotation*
# there were 27 classes trying to access generic signatures using reflection. You should consider keeping the signature attributes (using '-keepattributes Signature'). (http://proguard.sourceforge.net/manual/troubleshooting.html#attributes)
-keepattributes Signature
# Note: there were 3 classes trying to access enclosing classes using reflection. You should consider keeping the inner classes attributes (using '-keepattributes InnerClasses'). (http://proguard.sourceforge.net/manual/troubleshooting.html#attributes)
-keepattributes InnerClasses
# Note: there were 2 classes trying to access enclosing methods using reflection. You should consider keeping the enclosing method attributes (using '-keepattributes InnerClasses,EnclosingMethod'). (http://proguard.sourceforge.net/manual/troubleshooting.html#attributes)
-keepattributes InnerClasses,EnclosingMethod'
# Note: there were 50 unresolved dynamic references to classes or interfaces. You should check if you need to specify additional program jars. (http://proguard.sourceforge.net/manual/troubleshooting.html#dynamicalclass)

# Note: there were 1 class casts of dynamically created class instances. You might consider explicitly keeping the mentioned classes and/or their implementations (using '-keep'). (http://proguard.sourceforge.net/manual/troubleshooting.html#dynamicalclasscast)

# Note: there were 72 accesses to class members by means of introspection. You should consider explicitly keeping the mentioned class members (using '-keep' or '-keepclassmembers'). (http://proguard.sourceforge.net/manual/troubleshooting.html#dynamicalclassmember)