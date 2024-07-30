import 'dart:io';

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

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: InAppWebView(
            initialSettings: InAppWebViewSettings(transparentBackground: true),
            initialData: InAppWebViewInitialData(data: '<html><head></head><body></body></html>'),
          ),
        ),
      ],
    );
  }
}
