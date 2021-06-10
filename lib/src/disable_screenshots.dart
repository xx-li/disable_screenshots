import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'disable_screenshots_watarmark.dart';

class DisableScreenshots {
  static DisableScreenshots _singleton = DisableScreenshots._internal();
  factory DisableScreenshots() {
    return _singleton;
  }
  DisableScreenshots._internal();

  final MethodChannel _methodChannel =
      const MethodChannel("com.devlxx.DisableScreenshots/disableScreenshots");
  final EventChannel _eventChannel =
      const EventChannel('com.devlxx.DisableScreenshots/observer');

  OverlayEntry? _overlayEntry;
  Stream<void>? _onScreenShots;

  /// 获取监听截屏动作的[Stream]。用法：
  ///
  /// ```
  /// DisableScreenshots().onScreenShots.listen((event) {
  ///   print("监听到了截屏动作");
  /// });
  /// ```
  Stream<void> get onScreenShots {
    if (_onScreenShots == null) {
      _onScreenShots = _eventChannel.receiveBroadcastStream();
    }
    return _onScreenShots!;
  }

  /// 添加默认水印
  ///
  /// [watermark] 水印文案
  /// [rowCount] 水印文案每行显示的个数
  /// [columnCount] 水印文案每列显示的个数
  /// [textStyle] 水印文案的样式
  void addWatermark(BuildContext context, String watermark,
      {int rowCount = 3, int columnCount = 10, TextStyle? textStyle}) async {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
        builder: (context) => DisableScreenshotsWatarmark(
              rowCount: rowCount,
              columnCount: columnCount,
              text: watermark,
              textStyle: textStyle ??
                  const TextStyle(
                      color: Color(0x08000000),
                      fontSize: 18,
                      decoration: TextDecoration.none),
            ));
    overlayState?.insert(_overlayEntry!);
  }

  /// 添加自定义水印。将[widget]覆盖在所有视图的最上层
  void addCustomWatermark(BuildContext context, Widget widget) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (context) => widget);
    overlayState?.insert(_overlayEntry!);
  }

  /// 移除水印
  void removeWatermark() async {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  /// 只支持安卓
  Future<void> disableScreenshots(bool disable) async {
    if (Platform.isAndroid) {
      return await _methodChannel
          .invokeMethod("disableScreenshots", {"disable": disable});
    } else {
      print('仅Android平台支持禁用屏幕截图');
    }
  }
}
