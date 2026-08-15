pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // AGP must stay below 9 on this Flutter version. Flutter 3.44's Gradle
    // plugin unconditionally applies `kotlin-android` to every plugin project
    // (FlutterPluginUtils.detectApplyingKotlinGradlePlugin), which AGP 9 rejects
    // outright when built-in Kotlin is on — and with it off, plugins that gate
    // KGP on `AGP < 9` (file_picker, share_plus, package_info_plus) never get
    // their Kotlin compiled at all. 8.11.1 is Flutter 3.44's minimum non-warning
    // AGP version.
    id("com.android.application") version "8.11.1" apply false
    // Required on the classpath: Flutter applies this to plugin subprojects.
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
