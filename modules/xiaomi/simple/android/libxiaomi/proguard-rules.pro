# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html
# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}
# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable
# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

-keepattributes InnerClasses,Signature,Exceptions,Deprecated,*Annotation*
-keep class android.** {*;}
-keep class com.google.** {*;}
-keep class com.android.** {*;}
-keep class org.apache.** { *; }
-keep class sun.misc.Unsafe { *; }
-keep class com.google.zxing.** {*;}
#-libraryjars libs/alipaySdk.jar
-dontwarn com.alipay.**
-keep class com.alipay.** {*;}
-keep class com.ut.device.** {*;}
-keep class com.ta.utdid2.** {*;}
#-libraryjars libs/eventbus-3.jar
-keep class org.greenrobot.eventbus.** { *; }
-keep class de.greenrobot.event.** { *; }
-keep class de.greenrobot.dao.** {*;}
-keepclassmembers class ** {
    public void onEvent*(**);
        void onEvent*(**);
        }
    -keepclassmembers class ** {
    @org.greenrobot.eventbus.Subscribe <methods>;
    }
    -keep enum org.greenrobot.eventbus.ThreadMode { *; }
# Only required if you use AsyncExecutor
-keepclassmembers class * extends org.greenrobot.eventbus.util.ThrowableFailureEvent {
    <init>(java.lang.Throwable);
    }
    #-libraryjars libs/wechat.jar
-keep class com.tencent.** {*;}
#-libraryjars libs/glide.jar
-keep class com.bumptech.glide.** {*;}
-dontwarn com.xiaomi.**
-keep class com.xiaomi.** {*;}
-keep class com.mi.** {*;}
-keep class com.wali.** {*;}
-keep class miui.net.**{*;}
-keep class org.xiaomi.** {*;}