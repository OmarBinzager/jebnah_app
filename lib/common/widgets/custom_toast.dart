import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../helper/custom_snackbar_helper.dart';
import '../../../../utill/dimensions.dart';
import '../../../../utill/styles.dart';

class CustomToast {
  static final CustomToast _instance = CustomToast._internal();
  factory CustomToast() => _instance;
  CustomToast._internal();

  OverlayEntry? _overlayEntry;
  Timer? _toastTimer;

  void show(
    String message, {
    bool isError = true,
    SnackBarStatus? snackBarStatus,
    Duration duration = const Duration(seconds: 2),
    required GlobalKey<NavigatorState> navigatorKey,
    ToastPosition? position,
    bool animate = true,
    double? borderRadius,
  }) {
    _toastTimer?.cancel();
    _overlayEntry?.remove();

    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    final ctx = overlay.context;
    final effectivePosition = position ?? ToastPosition.topRight(ctx);

    _overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedToastWidget(
        message: message,
        isError: isError,
        snackBarStatus: snackBarStatus,
        position: effectivePosition,
        animate: animate,
        borderRadius: borderRadius,
      ),
    );

    overlay.insert(_overlayEntry!);

    _toastTimer = Timer(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }
}

class _AnimatedToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final SnackBarStatus? snackBarStatus;
  final ToastPosition position;
  final bool animate;
  final double? borderRadius;

  const _AnimatedToastWidget({
    required this.message,
    this.isError = true,
    this.snackBarStatus,
    required this.position,
    this.animate = true,
    this.borderRadius,
  });

  @override
  State<_AnimatedToastWidget> createState() => _AnimatedToastWidgetState();
}

class _AnimatedToastWidgetState extends State<_AnimatedToastWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _animation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );

      _animation = Tween<Offset>(
        begin: const Offset(1, 0),
        end: const Offset(0, 0),
      ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeOut));

      _controller?.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final toastContent = Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minHeight: 50, maxWidth: 400),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.snackBarStatus == SnackBarStatus.info
                ? const Icon(
                    Icons.warning_rounded,
                    color: Colors.orangeAccent,
                    size: 22,
                  )
                : CircleAvatar(
                    radius: 12,
                    backgroundColor: widget.isError ? Colors.red : Colors.green,
                    child: Icon(
                      widget.isError ? Icons.close_rounded : Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Flexible(
              child: Text(
                widget.message,
                style: poppinsRegular.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Positioned(
      top: widget.position.top,
      bottom: widget.position.bottom,
      left: widget.position.left,
      right: widget.position.right,
      child: widget.animate && _animation != null
          ? SlideTransition(position: _animation!, child: toastContent)
          : toastContent,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class ToastPosition {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const ToastPosition({this.top, this.bottom, this.left, this.right});

  // static fixed
  static const topCenter = ToastPosition(top: 50, left: 50, right: 50);
  static const bottomCenter = ToastPosition(bottom: 50, left: 50, right: 50);

  // dynamic
  factory ToastPosition.topRight(BuildContext context, {double top = 150}) {
    final width = MediaQuery.of(context).size.width;
    return ToastPosition(top: top, right: width * 0.2);
  }

  factory ToastPosition.bottomRight(
    BuildContext context, {
    double bottom = 50,
  }) {
    final width = MediaQuery.of(context).size.width;
    return ToastPosition(bottom: bottom, right: width * 0.1);
  }
}
