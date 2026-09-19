import 'package:flutter/material.dart';
import '../../../../utill/dimensions.dart';
import '../../../../utill/styles.dart';

enum TooltipPlacement { top, bottom, left, right }

enum TooltipTailPosition { start, center, end }

class CustomTooltip extends StatefulWidget {
  final Widget child;
  final String title;
  final String description;
  final IconData leadingIcon;
  final TooltipPlacement placement;
  final TooltipTailPosition tailPosition;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? toolTipGap;
  final double? leftOffset;
  final ScrollController? scrollController;

  const CustomTooltip({
    super.key,
    required this.child,
    required this.title,
    required this.description,
    required this.leadingIcon,
    this.placement = TooltipPlacement.bottom,
    this.tailPosition = TooltipTailPosition.center,
    this.backgroundColor,
    this.iconColor,
    this.toolTipGap = 10.0,
    this.scrollController,
    this.leftOffset = 0.0,
  });

  @override
  CustomTooltipState createState() => CustomTooltipState();
}

class CustomTooltipState extends State<CustomTooltip> with RouteAware {
  OverlayEntry? _overlayEntry;
  final GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    widget.scrollController?.addListener(_handleScroll);
  }

  @override
  void dispose() {
    super.dispose();

    widget.scrollController?.removeListener(_handleScroll);
    hideTooltip();
  }

  @override
  void didUpdateWidget(CustomTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_handleScroll);
      widget.scrollController?.addListener(_handleScroll);
    }
  }

  /// handle tooltip visibility on navigation
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    hideTooltip();
  }

  @override
  void didPushNext() {
    hideTooltip();
  }

  void _handleScroll() {
    hideTooltip();
  }

  void showTooltip(BuildContext context) {
    if (_overlayEntry != null) return;

    final renderBox = _childKey.currentContext!.findRenderObject() as RenderBox;
    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final tooltipWidth = 260.0;
        final tooltipHeight = 100.0;

        double left = targetPosition.dx;
        double top = targetPosition.dy;

        switch (widget.placement) {
          case TooltipPlacement.bottom:
            left = targetPosition.dx + (widget.leftOffset ?? 0.0);
            top =
                targetPosition.dy +
                targetSize.height +
                (widget.toolTipGap ?? 10.0);
            break;
          case TooltipPlacement.top:
            left = targetPosition.dx + (widget.leftOffset ?? 0.0);
            top =
                targetPosition.dy - tooltipHeight - (widget.toolTipGap ?? 10.0);
            break;
          case TooltipPlacement.left:
            left =
                targetPosition.dx - tooltipWidth - (widget.toolTipGap ?? 10.0);
            top = targetPosition.dy;
            break;
          case TooltipPlacement.right:
            left =
                targetPosition.dx +
                targetSize.width +
                (widget.toolTipGap ?? 10.0);
            top = targetPosition.dy;
            break;
        }

        return Positioned(
          left: left,
          top: top,
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.fontSizeSmall),
            ),
            color: Colors.transparent,
            child:
                (widget.placement == TooltipPlacement.left ||
                    widget.placement == TooltipPlacement.right)
                ? Row(
                    crossAxisAlignment: setTailPosition(),
                    children: [
                      if (widget.placement == TooltipPlacement.right)
                        _buildTail(isVertical: false),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.fontSizeSmall,
                          ),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Container(
                          width: tooltipWidth,
                          padding: const EdgeInsets.all(
                            Dimensions.fontSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            color:
                                widget.backgroundColor ??
                                Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(
                              Dimensions.fontSizeSmall,
                            ),
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: hideTooltip,
                                  child: const Icon(
                                    Icons.close,
                                    size: Dimensions.paddingSizeLarge,
                                  ),
                                ),
                              ),

                              Transform.translate(
                                offset: Offset(0, -10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      widget.leadingIcon,
                                      color:
                                          widget.iconColor ??
                                          Theme.of(context).primaryColor,
                                      size: Dimensions.paddingSizeExtraLarge,
                                    ),
                                    SizedBox(
                                      width: Dimensions.paddingSizeSmall,
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.title,
                                            style: poppinsRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                            ),
                                          ),
                                          SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),

                                          Text(
                                            widget.description,
                                            style: poppinsRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (widget.placement == TooltipPlacement.left)
                        _buildTail(isVertical: false),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: setTailPosition(),
                    children: [
                      if (widget.placement == TooltipPlacement.bottom)
                        _buildTail(isVertical: true),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.fontSizeSmall,
                          ),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Container(
                          width: tooltipWidth,
                          padding: const EdgeInsets.all(
                            Dimensions.fontSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            color:
                                widget.backgroundColor ??
                                Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(
                              Dimensions.fontSizeSmall,
                            ),
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: hideTooltip,
                                  child: const Icon(
                                    Icons.close,
                                    size: Dimensions.paddingSizeLarge,
                                  ),
                                ),
                              ),

                              Transform.translate(
                                offset: Offset(0, -10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      widget.leadingIcon,
                                      color:
                                          widget.iconColor ??
                                          Theme.of(context).primaryColor,
                                      size: Dimensions.paddingSizeExtraLarge,
                                    ),
                                    SizedBox(
                                      width: Dimensions.paddingSizeSmall,
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.title,
                                            style: poppinsRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),

                                          Text(
                                            widget.description,
                                            style: poppinsRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (widget.placement == TooltipPlacement.top)
                        _buildTail(isVertical: true),
                    ],
                  ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  CrossAxisAlignment setTailPosition() {
    return widget.tailPosition == TooltipTailPosition.start
        ? CrossAxisAlignment.start
        : widget.tailPosition == TooltipTailPosition.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.end;
  }

  Widget _buildTail({required bool isVertical}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isVertical ? Dimensions.paddingSizeSmall : 0,
      ),
      child: CustomPaint(
        size: isVertical ? const Size(20, 10) : const Size(10, 20),
        painter: _TooltipTailPainter(
          color: widget.backgroundColor ?? Theme.of(context).cardColor,
          placement: widget.placement,
        ),
      ),
    );
  }

  void hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(key: _childKey, child: widget.child);
  }
}

class _TooltipTailPainter extends CustomPainter {
  final Color color;
  final TooltipPlacement placement;

  _TooltipTailPainter({required this.color, required this.placement});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    switch (placement) {
      case TooltipPlacement.bottom:
        path.moveTo(size.width / 2, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case TooltipPlacement.top:
        path.moveTo(size.width / 2, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case TooltipPlacement.left:
        path.moveTo(size.width, size.height / 2);
        path.lineTo(0, 0);
        path.lineTo(0, size.height);
        break;
      case TooltipPlacement.right:
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
