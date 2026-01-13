# Flutter R8/ProGuard Rules

# Suppress warnings for AR Sceneform (used by ar_flutter_plugin but typically missing in release builds without full ARCore)
-dontwarn com.google.ar.sceneform.**

# Suppress warnings for Desugar runtime (often false positives with core library desugaring)
-dontwarn com.google.devtools.build.android.desugar.runtime.**

# Ensure Flutter's entry point is kept (standard rule)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Suppress warnings for Google Play Core (split install/updates) - these are optional and missing in some build configurations
-dontwarn com.google.android.play.core.**
