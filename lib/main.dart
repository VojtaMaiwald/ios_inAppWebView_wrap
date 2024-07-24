import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ios_wrap/inner_bottom_sheet.dart';
import 'package:ios_wrap/ios_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Wrap for InAppWebView',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'iOS Wrap for InAppWebView'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  OverlayEntry? _overlayEntry;
  DraggableScrollableController? _draggableScrollableController;
  ValueNotifier<bool> overlayVisible = ValueNotifier<bool>(true);
  double navigationBottomBarHeight = 56.0;

  @override
  void initState() {
    super.initState();

    _overlayEntry = _getOverlayEntry(context);
    // This callback ensures that the overlay entry is inserted AFTER the ForestScreen build method finishes
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry != null && !_overlayEntry!.mounted) {
        Overlay.of(context).insert(_overlayEntry!);
      }
    });
  }

  @override
  void dispose() {
    removeDraggableScrollableController();
    removeForestPlanBottomSheet();
    super.dispose();
  }

  void removeForestPlanBottomSheet() {
    removeDraggableScrollableController();
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  void removeDraggableScrollableController() {
    _draggableScrollableController?.dispose();
    _draggableScrollableController = null;
  }

  OverlayEntry _getOverlayEntry(BuildContext context) {
    _draggableScrollableController ??= DraggableScrollableController();
    return OverlayEntry(
      builder: (_) {
        final double minSheetHeight = kMinInteractiveDimension / MediaQuery.of(context).size.height;
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: navigationBottomBarHeight + 0.5),
            child: ValueListenableBuilder<bool>(
                valueListenable: overlayVisible,
                builder: (context, value, child) {
                  return Visibility(
                    maintainState: true,
                    visible: value,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InnerBottomSheet(
                        snap: true,
                        snapSizes: [
                          minSheetHeight,
                          0.5,
                          1.0 - ((MediaQuery.of(context).padding.top - 1) / MediaQuery.of(context).size.height),
                        ],
                        minChildSize: minSheetHeight,
                        initialChildSize: minSheetHeight,
                        controller: _draggableScrollableController,
                        wrapWithIosWrapper: true,
                        topShadow: true,
                        child: Column(
                          children: [
                            Image.network('https://docs.flutter.dev/assets/images/dash/dash-fainting.gif'),
                            ...List.generate(15, (index) {
                              return Container(
                                height: 150,
                                color: Colors.primaries[index % Colors.primaries.length],
                                child: Center(child: Text('Container $index')),
                              );
                            })
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
        );
      },
    );
  }

  Widget _getFab() {
    return IosWrapper(
      child: IconButton(
        icon: Icon(overlayVisible.value ? Icons.visibility_off : Icons.visibility),
        style: TextButton.styleFrom(
          iconColor: Colors.white,
          foregroundColor: Colors.blueAccent,
          backgroundColor: Colors.blue,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(1000)),
          ),
        ),
        onPressed: () => setState(() => overlayVisible.value = !overlayVisible.value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      bottomNavigationBar: Container(
        height: navigationBottomBarHeight,
        color: Theme.of(context).colorScheme.inversePrimary,
        child: const Center(child: Text('Navigation Bottom Bar')),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri('https://www.openstreetmap.org/')),
                onWebViewCreated: (webViewController) => InAppWebViewController.clearAllCache(),
                initialSettings: InAppWebViewSettings(
                  preferredContentMode: UserPreferredContentMode.MOBILE,
                  allowFileAccessFromFileURLs: true,
                  allowUniversalAccessFromFileURLs: true,
                ),
              ),
            ),
            ...List.generate(10, (index) {
              return Positioned(left: 10.0, top: 50.0 * index + 70, child: _getFab());
            }),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: overlayVisible.value ? const EdgeInsets.only(bottom: kMinInteractiveDimension) : EdgeInsets.zero,
        child: FloatingActionButton(
          onPressed: () => setState(() => overlayVisible.value = !overlayVisible.value),
          tooltip: 'FAB',
          child: Icon(overlayVisible.value ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }
}
