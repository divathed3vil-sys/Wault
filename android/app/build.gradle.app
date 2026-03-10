// android/app/build.gradle
// NOTE: This is the REPLACEMENT content for android/app/build.gradle.
// The flutter create template generates a similar file — replace the key
// sections (defaultConfig, compileOptions, kotlinOptions) as shown here.

plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace "com.diva.wault"
    compileSdk 34

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId "com.diva.wault"
        minSdk 26
        targetSdk 34
        versionCode flutter.versionCode
        versionName flutter.versionName
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
        }
    }
}

flutter {
    source "../.."
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
    implementation "androidx.core:core-ktx:1.13.1"
    implementation "androidx.appcompat:appcompat:1.7.0"
    implementation "androidx.webkit:webkit:1.11.0"
    implementation "com.google.android.material:material:1.12.0"
}
