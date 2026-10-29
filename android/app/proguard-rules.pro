# ==============================================================================
# ProGuard / R8 Configuration for GS PRO Mobile
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Flutter Framework & Engine
# ------------------------------------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Generated Plugin Registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep native methods called across Flutter channel
-keepclasseswithmembernames class * {
    native <methods>;
}

# ------------------------------------------------------------------------------
# 2. Application Entrypoint
# ------------------------------------------------------------------------------
-keep class com.gspro.app.MainActivity { *; }

# ------------------------------------------------------------------------------
# 3. Active Project Plugins
# ------------------------------------------------------------------------------

# open_filex & AndroidX FileProvider
-keep class com.crazecoder.openfile.** { *; }
-keep class androidx.core.content.FileProvider { *; }
-keep public class * extends androidx.core.content.FileProvider

# file_saver
-keep class com.incrediblezayed.file_saver.** { *; }

# device_info_plus & package_info_plus (plus plugins)
-keep class dev.fluttercommunity.plus.** { *; }

# shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# ------------------------------------------------------------------------------
# 4. Kotlin & AndroidX General Rules
# ------------------------------------------------------------------------------
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod,SourceFile,LineNumberTable

# Preserve Serializable & Parcelable implementations
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# ------------------------------------------------------------------------------
# 5. Suppress Harmless Warnings
# ------------------------------------------------------------------------------
-dontwarn kotlin.**
-dontwarn io.flutter.**
-dontwarn androidx.**
-dontwarn com.google.android.material.**
