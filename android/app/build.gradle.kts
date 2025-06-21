plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Correct way to apply plugin
}

android {
    namespace = "com.unicorn.edt.edt"
    compileSdk = 35 // or use flutter.compileSdkVersion if set in your flutter.gradle

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.unicorn.edt.edt"
        minSdk = 23
        targetSdk = 34 // or use flutter.targetSdkVersion
        versionCode = 1 // or use flutter.versionCode
        versionName = "1.0.0" // or use flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
