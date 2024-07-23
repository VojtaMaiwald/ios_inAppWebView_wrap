import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ios_wrap/ios_wrapper.dart';

class InnerBottomSheet extends StatefulWidget {
  const InnerBottomSheet({
    required this.child,
    super.key,
    this.snap = false,
    this.snapSizes,
    this.minChildSize = 0.25,
    this.maxChildSize = 1.0,
    this.initialChildSize = 0.5,
    this.wrapWithIosWrapper = false,
    this.controller,
    this.exportControllers,
    this.topShadow = false,
  });

  final Widget child;
  final bool snap;
  final List<double>? snapSizes;
  final double minChildSize;
  final double maxChildSize;
  final double initialChildSize;
  final bool wrapWithIosWrapper;
  final DraggableScrollableController? controller;
  final void Function(ScrollController?, DraggableScrollableController?)? exportControllers;
  final bool topShadow;

  @override
  State<InnerBottomSheet> createState() => _InnerBottomSheetSState();
}

class _InnerBottomSheetSState extends State<InnerBottomSheet> {
  final Size dragHandleSize = const Size(32, 4);
  final Color modalBarrier = const Color(0x8A000000);
  final Color darkLine = const Color(0xFFCCCCCC);
  final double borderRadius12 = 12.0;
  final double navigationBottomBarHeight = 56.0;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(draggableScrollableControllerListener);
  }

  @override
  void dispose() {
    widget.exportControllers?.call(null, null);
    super.dispose();
  }

  void draggableScrollableControllerListener() {
    setState(() {});
  }

  Positioned _getDragHandle(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).viewInsets.top,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius12)),
            border: Border(top: BorderSide(color: darkLine, width: 0.5)),
          ),
          child: SizedBox(
            height: kMinInteractiveDimension,
            width: kMinInteractiveDimension,
            child: Center(
              child: Container(
                height: dragHandleSize.height,
                width: dragHandleSize.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(dragHandleSize.height / 2),
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool barrierVisible = widget.topShadow &&
        (widget.controller?.isAttached ?? false) &&
        (widget.controller?.size ?? -1) >= (widget.snapSizes?.last ?? widget.maxChildSize) - 0.01;
    return Stack(
      children: [
        if (widget.topShadow)
          Visibility(
            visible: barrierVisible,
            maintainAnimation: true,
            maintainState: true,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeIn,
              opacity: barrierVisible ? 1.0 : 0,
              child: SizedBox.expand(child: ColoredBox(color: modalBarrier)),
            ),
          ),
        DraggableScrollableSheet(
          controller: widget.controller,
          snap: widget.snap,
          snapSizes: widget.snapSizes,
          minChildSize: widget.minChildSize,
          maxChildSize: widget.snapSizes?.last ?? widget.maxChildSize,
          initialChildSize: widget.initialChildSize,
          builder: (context, scrollController) {
            widget.exportControllers?.call(scrollController, widget.controller);

            if (widget.wrapWithIosWrapper) {
              return IosWrapper(
                wrapTopPadding: kDebugMode ? 25 : null,
                child: _getSheetContent(scrollController, context),
              );
            }
            return _getSheetContent(scrollController, context);
          },
        ),
      ],
    );
  }

  Widget _getSheetContent(ScrollController scrollController, BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius12)),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.only(top: kMinInteractiveDimension),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      kMinInteractiveDimension -
                      MediaQuery.of(context).viewPadding.top -
                      navigationBottomBarHeight +
                      1,
                ),
                child: widget.child,
              ),
            ),
          ),
          _getDragHandle(context),
          Positioned(
            top: kMinInteractiveDimension - 0.5 + MediaQuery.of(context).viewInsets.top,
            left: 0,
            right: 0,
            child: StatefulBuilder(
              builder: (context, setState) {
                if (scrollController.positions.isNotEmpty && !scrollController.hasListeners) {
                  scrollController.addListener(() {
                    setState(() {});
                  });
                }
                if (scrollController.positions.isNotEmpty && scrollController.offset > 0.0) {
                  return Container(
                    width: double.infinity,
                    height: 0.5,
                    color: darkLine,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
