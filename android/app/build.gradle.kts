import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 기존 Capacitor 빌드와 동일한 keystore를 재사용 → SHA-1 신규 등록 없이
// Play Store 자동 업데이트로 v1.1.17 → Flutter 빌드 이어 받기 가능.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("../keystore.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
// CI(.github/workflows/play-release.yml)는 keystore.properties 대신 환경 변수로 넘긴다.
// BRIODO_UPLOAD_STORE_FILE 이 있으면 파일 값보다 환경 변수가 우선한다.
val signingFromEnv = !System.getenv("BRIODO_UPLOAD_STORE_FILE").isNullOrBlank()
if (signingFromEnv) {
    keystoreProperties["storeFile"] = System.getenv("BRIODO_UPLOAD_STORE_FILE")
    keystoreProperties["storePassword"] = System.getenv("BRIODO_UPLOAD_STORE_PASSWORD")
    keystoreProperties["keyAlias"] = System.getenv("BRIODO_UPLOAD_KEY_ALIAS")
    keystoreProperties["keyPassword"] = System.getenv("BRIODO_UPLOAD_KEY_PASSWORD")
}
val hasReleaseSigning = signingFromEnv || keystorePropertiesFile.exists()

android {
    namespace = "app.briodo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications 21+ 요구사항
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "app.briodo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"] as String?
            if (storeFilePath != null) {
                val resolved = file(storeFilePath).let { f ->
                    if (f.exists()) f else rootProject.file("../$storeFilePath")
                }
                storeFile = resolved
                storePassword = keystoreProperties["storePassword"] as String?
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            // keystore.properties·환경 변수 둘 다 없으면 debug 키로 폴백 (flutter run --release 동작용)
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // minify는 ProGuard 규칙 정리 후 활성화 예정 (Firebase/Riverpod 클래스 보존 필요)
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

// home_widget 0.9.1 가 androidx.glance:glance-appwidget:1.+ 로 동적 버전을 요청해
// Google이 최근 푸시한 1.3.0-alpha01 (AGP 9.1+, compileSdk 37+ 요구)이 끌려오는 사고를 막는다.
// 안정판 1.1.1로 강제.
configurations.all {
    resolutionStrategy {
        force("androidx.glance:glance-appwidget:1.1.1")
        force("androidx.glance:glance:1.1.1")
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.google.mediapipe:tasks-genai:0.10.14")
}
