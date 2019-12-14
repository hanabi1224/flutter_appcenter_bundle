package com.github.hanabi1224.flutter_appcenter_bundle

import android.app.Application
import android.util.Log
import androidx.annotation.NonNull
import com.microsoft.appcenter.AppCenter
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.crashes.Crashes
import com.microsoft.appcenter.distribute.Distribute
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** FlutterAppcenterBundlePlugin */
class FlutterAppcenterBundlePlugin : FlutterPlugin, MethodCallHandler {
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val tag = "onAttachedToEngine"
        var context = flutterPluginBinding.applicationContext
        while (context != null) {
            Log.w(tag, "Trying to resolve Application from Context: ${context.javaClass.name}")
            application = context as Application
            if (application != null) {
                Log.i(tag, "Resolved Application from Context")
                break
            } else {
                context = context.applicationContext
            }
        }
        if (application == null) {
            Log.e(tag, "Fail to resolve Application from Context")
        }

        val channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, methodChannelName)
        channel.setMethodCallHandler(FlutterAppcenterBundlePlugin())
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        const val methodChannelName = "com.github.hanabi1224.flutter_appcenter_bundle"

        var application: Application? = null

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            application = registrar.activity().application
            val channel = MethodChannel(registrar.messenger(), methodChannelName)
            channel.setMethodCallHandler(FlutterAppcenterBundlePlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.d("onMethodCall", "[${methodChannelName}] ${call.method}")
        try {
            when (call.method) {
                "start" -> {
                    if (application == null) {
                        val error = "Fail to resolve Application on registration"
                        Log.e(call.method, error)
                        result.error(call.method, error, Exception(error))
                        return
                    }

                    val appSecret = call.arguments as String
                    if (appSecret == null || appSecret.isEmpty()) {
                        val error = "App secret is not set"
                        Log.e(call.method, error)
                        result.error(call.method, error, Exception(error))
                        return
                    }

                    AppCenter.start(application, appSecret, Analytics::class.java, Crashes::class.java, Distribute::class.java)
                }
                "trackEvent" -> {
                    val name = call.argument<String>("name")
                    val properties = call.argument<Map<String, String>>("properties")
                    Analytics.trackEvent(name, properties)
                }
                "isDistributeEnabled" -> {
                    result.success(Distribute.isEnabled().get())
                    return
                }
                "configureDistribute" -> {
                    val value = call.arguments as Boolean
                    Distribute.setEnabled(value).get()
                }
                "configureDistributeDebug" -> {
                    val value = call.arguments as Boolean
                    Distribute.setEnabledForDebuggableBuild(value)
                }
                "isCrashesEnabled" -> {
                    result.success(Crashes.isEnabled().get())
                    return
                }
                "configureCrashes" -> {
                    val value = call.arguments as Boolean
                    Crashes.setEnabled(value).get()
                }
                "isAnalyticsEnabled" -> {
                    result.success(Analytics.isEnabled().get())
                    return
                }
                "configureAnalytics" -> {
                    val value = call.arguments as Boolean
                    Analytics.setEnabled(value).get()
                }
                else -> {
                    result.notImplemented()
                }
            }

            result.success(null)
        } catch (error: Exception) {
            Log.e("onMethodCall", methodChannelName, error)
            throw error
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
