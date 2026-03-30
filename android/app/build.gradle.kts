plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.offroad.offroadist"
    compileSdk = flutter.compileSdkVersion
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
            keyAlias = System.getenv("CM_KEY_ALIAS") ?: "offroad"
            keyPassword = System.getenv("CM_KEY_PASSWORD") ?: "Batu329388x"
            storeFile = System.getenv("CM_KEYSTORE_PATH")?.let { file(it) }
            storePassword = System.getenv("CM_STORE_PASSWORD") ?: "Batu329388x"
        }
    }

    defaultConfig {
        applicationId = "com.offroad.offroadist"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
