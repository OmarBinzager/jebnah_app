import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../helper/route_helper.dart';
import '../../main.dart';
import '../../utill/dimensions.dart';
import '../../utill/styles.dart';
import 'custom_image_widget.dart';

class InAppNotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final String? image;
  final int? orderId;
  final String? type;
  final String? userName;
  final String? profileImage;
  final String? senderType;
  final VoidCallback onDismiss;

  const InAppNotificationBanner({
    super.key,
    required this.title,
    required this.body,
    this.image,
    this.orderId,
    this.type,
    this.userName,
    this.profileImage,
    this.senderType,
    required this.onDismiss,
  });

  static OverlayEntry? _activeEntry;

  static void show({
    required String title,
    required String body,
    String? image,
    int? orderId,
    String? type,
    String? userName,
    String? profileImage,
    String? senderType,
  }) {
    final context = navigatorKey.currentContext ?? Get.context;
    if (context == null) return;

    final overlayState = navigatorKey.currentState?.overlay ?? Overlay.of(context);

    // Dismiss any existing active banner first
    _activeEntry?.remove();
    _activeEntry = null;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => InAppNotificationBanner(
        title: title,
        body: body,
        image: image,
        orderId: orderId,
        type: type,
        userName: userName,
        profileImage: profileImage,
        senderType: senderType,
        onDismiss: () {
          entry?.remove();
          if (_activeEntry == entry) {
            _activeEntry = null;
          }
        },
      ),
    );

    _activeEntry = entry;
    overlayState.insert(entry);
  }

  @override
  State<InAppNotificationBanner> createState() => _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    _playNotificationSound();

    _dismissTimer = Timer(const Duration(seconds: 5), () {
      _dismiss();
    });
  }

  Future<void> _playNotificationSound() async {
    try {
      HapticFeedback.lightImpact();
      final AudioPlayer player = AudioPlayer();
      await player.play(AssetSource('notification.wav'));
    } catch (e) {
      if (kDebugMode) {
        print('In-app notification sound error: $e');
      }
    }
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    if (mounted) {
      _controller.reverse().then((_) {
        widget.onDismiss();
      });
    } else {
      widget.onDismiss();
    }
  }

  void _onTap() {
    _dismiss();

    try {
      if (widget.orderId != null && widget.type == 'message') {
        RouteHelper.getChatRoute(
          orderId: widget.orderId.toString(),
          userName: widget.userName ?? '',
          profileImage: widget.profileImage ?? '',
          senderType: widget.senderType ?? 'admin',
          isAppBar: true,
        );
      } else if (widget.orderId != null) {
        RouteHelper.getOrderDetailsRoute(widget.orderId.toString());
      } else if (widget.type == 'message') {
        RouteHelper.getChatRoute(
          orderId: widget.orderId?.toString() ?? '0',
          userName: widget.userName ?? '',
          profileImage: widget.profileImage ?? '',
          senderType: widget.senderType ?? 'admin',
          isAppBar: true,
        );
      } else if (widget.type == 'wallet') {
        RouteHelper.getWalletRoute();
      } else {
        RouteHelper.getNotificationScreen();
      }
    } catch (e) {
      if (kDebugMode) {
        print('In-app notification navigation error: $e');
      }
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding > 0 ? topPadding + 8 : 16,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! < -5) {
                _dismiss();
              }
            },
            onTap: _onTap,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.18),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: poppinsBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.body,
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (widget.image != null && widget.image!.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomImageWidget(
                          image: widget.image!,
                          height: 42,
                          width: 42,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Theme.of(context).hintColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
