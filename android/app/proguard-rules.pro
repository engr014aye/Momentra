# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep SQLite / sqflite
-keep class com.tekartik.sqflite.** { *; }

# Keep models (if using reflection)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable

# Ignore missing Play Core classes referenced by Flutter's deferred components
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
