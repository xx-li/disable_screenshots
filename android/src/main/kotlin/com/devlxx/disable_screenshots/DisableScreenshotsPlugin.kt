package com.devlxx.disable_screenshots

import android.app.Activity
import android.content.Context
import android.util.Log
import android.view.WindowManager
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlin.coroutines.coroutineContext

/** DisableScreenshotsPlugin */
public class DisableScreenshotsPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var applicationContext: Context;
  private lateinit var activity: Activity;
  private var eventSink: EventChannel.EventSink? = null
  private lateinit var screenShotListenManager: ScreenShotListenManager;
  var disableScreenshots: Boolean = false

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    onAttachedToEngine(flutterPluginBinding.applicationContext, flutterPluginBinding.binaryMessenger)
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
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val plugin = DisableScreenshotsPlugin()
      plugin.activity = registrar.activity()
      plugin.onAttachedToEngine(registrar.context(), registrar.messenger())
    }
  }

  private fun onAttachedToEngine(applicationContext: Context, messenger: BinaryMessenger) {
    this.applicationContext = applicationContext
    this.channel = MethodChannel(messenger, "com.devlxx.DisableScreenshots/disableScreenshots")
    val eventChannel = EventChannel(messenger, "com.devlxx.DisableScreenshots/observer")
    this.channel.setMethodCallHandler(this)
    eventChannel.setStreamHandler(this)
  }

  private fun setDisableScreenshotsStatus(disable: Boolean) {
    if (disable) { // 禁用截屏
      activity.window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE);
      println("禁用截屏")
    } else { // 允许截屏
      activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
      println("允许截屏")
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "disableScreenshots") {
      var disable = call.argument<Boolean>("disable") == true
      setDisableScreenshotsStatus(disable)
      result.success("")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    println("开始监听")
    eventSink = events
    screenShotListenManager = ScreenShotListenManager.newInstance(applicationContext)
    screenShotListenManager.setListener { imagePath ->
      println("监听到截屏，截屏地址是：$imagePath")
      eventSink?.success("")
    }
    screenShotListenManager.startListen()
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }


  override fun onDetachedFromActivity() {

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    setDisableScreenshotsStatus(this.disableScreenshots)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    setDisableScreenshotsStatus(this.disableScreenshots)
  }

  override fun onDetachedFromActivityForConfigChanges() {

  }
}
