plugins {
    id("com.android.application")
    id("kotlin-android")
    // 👇 SỬA LẠI: Chỉ gọi ID thôi, bỏ version và apply false đi
    id("com.google.gms.google-services") 
}

android {
    namespace = "com.example.flutter_app_1771020643" // Cái này giữ nguyên ok
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // 👇 ID này chuẩn rồi
        applicationId = "com.example.id1771020643" 
        
        // 👇 SỬA LẠI: Đổi thành số 21 (Bắt buộc cho Firestore)
        minSdk = 21 
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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