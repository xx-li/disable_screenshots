import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DisableScreenshots {
  static DisableScreenshots _instance;
  factory DisableScreenshots() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          "com.devlxx.DisableScreenshots/disableScreenshots");
      final EventChannel eventChannel =
          const EventChannel('com.devlxx.DisableScreenshots/observer');
      _instance = DisableScreenshots.private(methodChannel, eventChannel);
    }
    return _instance;
  }

  DisableScreenshots.private(this._methodChannel, this._eventChannel);
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  Stream<void> _onScreenShots;

  OverlayEntry _overlayEntry;

  void addWatermark(BuildContext context, String watermark,
      {int rowCount = 3, int columnCount = 10, TextStyle textStyle}) async {
    if (_overlayEntry != null) {
      _overlayEntry.remove();
    }
    OverlayState overlayState = Overlay.of(context);
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
    overlayState.insert(_overlayEntry);
    // return await _methodChannel.invokeMethod<void>("addWatermark", ['我是水印']);
  }

  void addCustomWatermark(BuildContext context, Widget widget) {
    if (_overlayEntry != null) {
      _overlayEntry.remove();
    }
    OverlayState overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (context) => widget);
    overlayState.insert(_overlayEntry);
  }

  void removeWatermark() async {
    if (_overlayEntry != null) {
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  Stream<void> get onScreenShots {
    if (_onScreenShots == null) {
      _onScreenShots = _eventChannel.receiveBroadcastStream();
    }
    return _onScreenShots;
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

class DisableScreenshotsWatarmark extends StatelessWidget {
  final int rowCount;
  final int columnCount;
  final String text;
  final TextStyle textStyle;

  const DisableScreenshotsWatarmark({
    Key key,
    @required this.rowCount,
    @required this.columnCount,
    @required this.text,
    @required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
          child: Column(
        children: creatColumnWidgets(),
      )),
    );
  }

  List<Widget> creatRowWdiges() {
    List<Widget> list = [];
    for (var i = 0; i < rowCount; i++) {
      final widget = Expanded(
          child: Center(
              child: Transform.rotate(
                  angle: pi / 10, child: Text(text, style: textStyle))));
      list.add(widget);
    }
    return list;
  }

  List<Widget> creatColumnWidgets() {
    List<Widget> list = [];
    for (var i = 0; i < columnCount; i++) {
      final widget = Expanded(
          child: Row(
        children: creatRowWdiges(),
      ));
      list.add(widget);
    }
    return list;
  }
}
