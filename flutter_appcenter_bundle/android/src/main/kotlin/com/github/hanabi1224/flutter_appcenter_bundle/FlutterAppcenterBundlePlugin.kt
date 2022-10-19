package com.github.hanabi1224.flutter_appcenter_bundle

import android.app.Application
import android.util.Log
import androidx.annotation.NonNull
import com.microsoft.appcenter.AppCenter
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.crashes.Crashes
import com.microsoft.appcenter.crashes.ingestion.models.ErrorAttachmentLog
import com.microsoft.appcenter.distribute.Distribute
import com.microsoft.appcenter.distribute.UpdateTrack
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** FlutterAppcenterBundlePlugin */
class FlutterAppcenterBundlePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(flutterPluginBinding.binaryMessenger, methodChannelName)
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
            application = registrar.activity()?.application
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

                    val appSecret = call.argument<String>("secret")
                    val usePrivateTrack = call.argument<Boolean>("usePrivateTrack")
                    if (usePrivateTrack == true){
                        Distribute.setUpdateTrack(UpdateTrack.PRIVATE)
                    }

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
                "getInstallId" -> {
                    result.success(AppCenter.getInstallId().get()?.toString())
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
                "disableAutomaticCheckForUpdate" -> {
                    Distribute.disableAutomaticCheckForUpdate()
                }
                "checkForUpdate" -> {
                    Distribute.checkForUpdate()
                }
                "isCrashesEnabled" -> {
                    result.success(Crashes.isEnabled().get())
                    return
                }
                "configureCrashes" -> {
                    val value = call.arguments as Boolean
                    Crashes.setEnabled(value).get()
                }
                "trackError" -> {
                    val exception = Exception(call.argument<String>("exceptionStringRepresentation"))
                    val stackTrace = call.argument<String?>("stacktrace")
                    if(stackTrace != null) {
                        exception.stackTrace = stackTrace.split('\n').flatMap { line ->
                            val regex =
                                "^#\\d* *(?<methodName>[a-zA-Z1-9_]*).*\\((?<fileName>[a-zA-Z0-9:_/.]*.dart):(?<lineNumber>\\d*).*\$".toRegex()
                            
                            val stackTraceLine : Array<StackTraceElement> = if (regex.matches(line)) {
                                val groups =
                                    regex.matchEntire(line)!!.groups as? MatchNamedGroupCollection
                                val fileName = groups!!["fileName"]!!.value
                                val methodName = groups["methodName"]!!.value
                                val lineNumber = groups["lineNumber"]!!.value.toInt()
                                
                                arrayOf(
                                    StackTraceElement(
                                        fileName,
                                        methodName,
                                        fileName,
                                        lineNumber
                                    )
                                )
                            } else {
                                emptyArray()
                            }
                            stackTraceLine.toList()
                        }.toTypedArray()
                    }
                    val properties = call.argument<Map<String, String>?>("properties")
                    var errorAttachmentLog: ErrorAttachmentLog? = null
                    if(stackTrace != null){
                        errorAttachmentLog = ErrorAttachmentLog.attachmentWithText(stackTrace, "stacktrace.txt")
                    }
                    Crashes.trackError(exception, properties, listOfNotNull(errorAttachmentLog))
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

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val activity = binding.activity
        application = activity.application
    }

    override fun onDetachedFromActivity() {
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }
}
