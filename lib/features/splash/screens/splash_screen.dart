import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../common/enums/data_source_enum.dart';
import '../../../common/enums/notification_type.dart';
import '../../../common/models/config_model.dart';
import '../../../common/models/notification_body.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../../../helper/maintenance_helper.dart';
import '../../../helper/notification_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/images.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  StreamSubscription<List<ConnectivityResult>>? subscription;
  NotificationBody? notificationBody;
  bool isNotLoaded = true;

  late AnimationController _animationController;
  late AnimationController _lottieController;
  late Animation<double> _fadeAnimation;

  final DateTime _startTime = DateTime.now();

  @override
  void dispose() {
    subscription?.cancel();
    _animationController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _lottieController = AnimationController(vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    triggerFirebaseNotification();
    _checkConnectivity();
    Provider.of<SplashProvider>(context, listen: false).initSharedData();
    Provider.of<CartProvider>(context, listen: false).getCartData();
    _route();
  }

  Future<void> triggerFirebaseNotification() async {
    try {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (remoteMessage != null) {
        notificationBody = NotificationHelper.convertNotification(
          remoteMessage.data,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _route() {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );
    splashProvider.initConfig(context, source: DataSourceEnum.local).then((
      configModel,
    ) async {
      if (configModel != null && mounted) {
        _onConfigAction(configModel, splashProvider, context);
      }
    });
  }

  void _onConfigAction(
    ConfigModel? configModel,
    SplashProvider splashProvider,
    BuildContext context,
  ) {
    if (configModel != null) {
      splashProvider.getDeliveryInfo();
      splashProvider.initializeScreenList();

      double minimumVersion = 0.0;
      if (Platform.isAndroid) {
        if (splashProvider.configModel?.playStoreConfig?.minVersion != null) {
          minimumVersion =
              splashProvider.configModel?.playStoreConfig?.minVersion ??
              AppConstants.appVersion;
        }
      } else if (Platform.isIOS) {
        if (splashProvider.configModel?.appStoreConfig?.minVersion != null) {
          minimumVersion =
              splashProvider.configModel?.appStoreConfig?.minVersion ??
              AppConstants.appVersion;
        }
      }

      final int elapsedTime = DateTime.now()
          .difference(_startTime)
          .inMilliseconds;
      final int remainingTime = (5000 - elapsedTime).clamp(0, 5000);

      Future.delayed(Duration(milliseconds: remainingTime)).then((_) {
        if (!mounted) return;

        if (AppConstants.appVersion < minimumVersion &&
            !ResponsiveHelper.isWeb()) {
          RouteHelper.getUpdateRoute(
            action: RouteAction.pushNamedAndRemoveUntil,
          );
        } else {
          if (MaintenanceHelper.isMaintenanceModeEnable(configModel) &&
              MaintenanceHelper.isCustomerMaintenanceEnable(configModel)) {
            if (mounted) {
              RouteHelper.getMainRoute(
                action: RouteAction.pushNamedAndRemoveUntil,
              );
            }
          } else if (notificationBody != null) {
            notificationRoute();
          } else if (Provider.of<AuthProvider>(
            Get.context!,
            listen: false,
          ).isLoggedIn()) {
            Provider.of<AuthProvider>(
              Get.context!,
              listen: false,
            ).updateToken();
            RouteHelper.getMainRoute(
              action: RouteAction.pushNamedAndRemoveUntil,
            );
          } else {
            if (Provider.of<SplashProvider>(
              Get.context!,
              listen: false,
            ).showIntro()) {
              RouteHelper.getOnboardingScreen(
                action: RouteAction.pushNamedAndRemoveUntil,
              );
            } else {
              RouteHelper.getMainRoute(
                action: RouteAction.pushNamedAndRemoveUntil,
              );
            }
          }
        }
      });
    }
  }

  void _checkConnectivity() {
    bool isFirst = true;
    subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      bool isConnected =
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);

      if ((isFirst && !isConnected) || !isFirst && context.mounted) {
        showCustomSnackBarHelper(
          getTranslated(
            isConnected ? 'connected' : 'no_internet_connection',
            Get.context!,
          ),
          isError: !isConnected,
        );

        if (isConnected &&
            ModalRoute.of(Get.context!)?.settings.name == RouteHelper.splash) {
          _route();
        }
      }
      isFirst = false;
    });
  }

  void notificationRoute() {
    if (notificationBody?.type?.isNotEmpty ?? false) {
      NotificationType? notificationType = getNotificationTypeEnum(
        notificationBody?.type,
      );

      switch (notificationType) {
        case NotificationType.order:
          RouteHelper.getOrderDetailsRoute(
            notificationBody?.orderId.toString(),
            action: RouteAction.pushNamedAndRemoveUntil,
          );
          break;
        case NotificationType.message:
          RouteHelper.getChatRoute(
            orderId: notificationBody?.orderId.toString() ?? "",
            senderType: notificationBody?.senderType ?? "admin",
            userName: notificationBody?.userName ?? "",
            profileImage: notificationBody?.userImage ?? "",
            isAppBar: true,
            action: RouteAction.pushNamedAndRemoveUntil,
          );
          break;
        case NotificationType.general:
          RouteHelper.getNotificationScreen(
            action: RouteAction.pushNamedAndRemoveUntil,
          );
          break;
        case NotificationType.wallet:
          RouteHelper.getWalletRoute(
            status: '',
            action: RouteAction.pushNamedAndRemoveUntil,
          );
          break;
        case null:
          debugPrint(
            '==============Notification type does not exist============${notificationBody?.type}',
          );
          RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Transform.scale(
                scale: 1.8,
                alignment: Alignment.center,
                child: Lottie.asset(
                  'assets/lottie/jebnah_full_logo_animation.json',
                  width: size.width * 0.95,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  animate: true,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      Images.splashlogo,
                      width: 260,
                      height: 260,
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
