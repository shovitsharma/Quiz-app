# Flutter's core ProGuard rules.
-dontwarn io.flutter.embedding.**

# Rules for OkHttp, a common dependency in http and socket_io_client
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# Rules for Okio, a dependency of OkHttp
-keep class okio.** { *; }
-dontwarn okio.**