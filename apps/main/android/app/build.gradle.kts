import java.util.Properties

// Load signing properties from key.properties if it exists.
// Do NOT commit key.properties or the keystore file to version control.
val keyPropsFile = rootProject.file("key.properties")
val keyProps = Properties().apply {
    if (keyPropsFile.exists()) keyPropsFile.inputStream().use { load(it) }
}
val releaseStorePassword =
    keyProps["storePassword"] as String? ?: System.getenv("TRIVA_ANDROID_STORE_PASSWORD") ?: ""
val releaseKeyPassword =
    keyProps["keyPassword"] as String? ?: System.getenv("TRIVA_ANDROID_KEY_PASSWORD") ?: ""

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "id.rnq.triva"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = keyProps["keyAlias"] as String? ?: ""
            keyPassword = releaseKeyPassword
            storeFile = (keyProps["storeFile"] as String?)?.let { file(it) }
            storePassword = releaseStorePassword
        }
    }

    defaultConfig {
        applicationId = "id.rnq.triva"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Release artifacts must never silently fall back to a debug key.
            // A missing local key.properties/store file makes Gradle's signing
            // validation fail while debug builds remain unaffected.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
