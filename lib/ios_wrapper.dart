import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class IosWrapper extends StatelessWidget {
  const IosWrapper({
    required this.child,
    super.key,
    this.wrapTopPadding,
  });

  final Widget child;
  final double? wrapTopPadding;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return child;
    }

    //Don't ask me why, but using transparent ColoredBox with IgnorePointer and top and bottom
    //paddings significantly decreases chance of app to crash on iOS in debug because of map wrapping
    //But it is still not bulletproof
    //TODO find some ultimate solution for movable and resizable wrapping
    return Stack(
      children: [
        child,
        Positioned.fill(
          top: kDebugMode ? (wrapTopPadding ?? 1.0) : 0.0,
          bottom: kDebugMode  ? 1.0 : 0.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            child: IgnorePointer(
              child: ColoredBox(
                color: Colors.transparent,
                child: InAppWebView(
                  initialSettings: InAppWebViewSettings(transparentBackground: true),
                  initialData: InAppWebViewInitialData(data: '<html><head></head><body></body></html>'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
