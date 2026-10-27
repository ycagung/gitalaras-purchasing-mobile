import java.io.File
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// android/key.properties is gitignored (see android/.gitignore) - it holds the
// path/passwords for the upload keystore used to sign release builds. Falls
// back to debug signing when it's absent so a fresh checkout still builds.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.gspro.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.gspro.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                val storeFilePath = keystoreProperties["storeFile"] as String?
                storeFile = if (storeFilePath != null) {
                    val fileName = File(storeFilePath).name
                    val localFile = file(storeFilePath)
                    val localByName = file(fileName)
                    val localJks = file("$storeFilePath.jks")
                    val rootFile = rootProject.file(storeFilePath)
                    val rootByName = rootProject.file("app/$fileName")
                    val rootJks = rootProject.file("$storeFilePath.jks")
                    when {
                        localFile.exists() -> localFile
                        localByName.exists() -> localByName
                        localJks.exists() -> localJks
                        rootFile.exists() -> rootFile
                        rootByName.exists() -> rootByName
                        rootJks.exists() -> rootJks
                        else -> localFile
                    }
                } else {
                    null
                }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // No key.properties yet - fall back to debug signing so
                // `flutter build`/`flutter run --release` still work locally.
                // A real upload keystore is required before this can be
                // uploaded to the Play Store.
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
