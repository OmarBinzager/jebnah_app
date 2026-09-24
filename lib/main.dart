import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'common/enums/app_mode_enum.dart';
import 'common/enums/data_source_enum.dart';
import 'features/auth/providers/verification_provider.dart';
import 'features/home/providers/flash_deal_provider.dart';
import 'features/order/providers/image_note_provider.dart';
import 'features/order_track/providers/tracker_provider.dart';
import 'features/review/providers/review_provider.dart';

import 'helper/notification_helper.dart';
import 'helper/responsive_helper.dart';
import 'helper/route_helper.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/banner_provider.dart';
import 'features/brand/providers/brand_provider.dart';
import 'features/home/providers/seller_provider.dart';
import 'common/providers/cart_provider.dart';
import 'features/category/providers/category_provider.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/coupon/providers/coupon_provider.dart';

import 'common/providers/language_provider.dart';
import 'common/providers/localization_provider.dart';
import 'features/address/providers/location_provider.dart';
import 'common/providers/news_letter_provider.dart';
import 'features/notification/providers/notification_provider.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/order/providers/order_provider.dart';
import 'common/providers/product_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/search/providers/search_provider.dart';
import 'features/splash/providers/splash_provider.dart';
import 'common/providers/theme_provider.dart';
import 'features/wallet_and_loyalty/providers/wallet_provider.dart';
import 'features/wishlist/providers/wishlist_provider.dart';
import 'theme/dark_theme.dart';
import 'theme/light_theme.dart';
import 'utill/app_constants.dart';
import 'common/widgets/third_party_chat_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'di_container.dart' as di;
import 'features/auth/providers/facebook_login_provider.dart';

import 'localization/app_localization.dart';
import 'common/widgets/cookies_widget.dart';
import 'package:universal_html/html.dart' as html;
import 'package:app_links/app_links.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Firebase: ${e.toString()}');
    }
  }

  try {
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  } catch (e) {
    if (kDebugMode) {
      print('Error registering background message handler: $e');
    }
  }

  await di.init();
  String? path;
  try {
    if (!kIsWeb) {
      path = await initDynamicLinks();
    }
  } catch (e) {
    if (kDebugMode) {
      print('error---> ${e.toString()}');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => di.sl<ThemeProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<LocalizationProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => di.sl<SplashProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<OnBoardingProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => di.sl<CategoryProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ProductProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<SearchProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ChatProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<CartProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<CouponProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<LocationProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<OrderProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<BannerProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<BrandProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<SellerProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<NotificationProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => di.sl<LanguageProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<NewsLetterProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => di.sl<WishListProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<WalletAndLoyaltyProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => di.sl<FlashDealProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ReviewProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<VerificationProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => di.sl<OrderImageNoteProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => di.sl<TrackerProvider>()),
        ChangeNotifierProvider(
          create: (context) => di.sl<FacebookLoginProvider>(),
        ),
      ],
      child: MyApp(isWeb: !kIsWeb, route: path),
    ),
  );

  // Initialize notifications asynchronously in background without blocking UI
  _initNotifications();
}

void _initNotifications() async {
  if (kIsWeb) {
    if (AppConstants.appMode != AppMode.demo) {
      await FacebookAuth.instance.webAndDesktopInitialize(
        appId: "1216934565526698",
        cookie: true,
        xfbml: true,
        version: "v15.0",
      );
    }
  } else {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permission: $e');
      }
    }

    try {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error setting foreground notification options: $e');
      }
    }

    try {
      await FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic: $e');
      }
    }

    try {
      await NotificationHelper.initialize();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NotificationHelper: $e');
      }
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (kDebugMode) {
        print('----------------------------------------');
        print('FCM TOKEN: $token');
        print('----------------------------------------');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
    }
  }
}

class MyApp extends StatefulWidget {
  final int? orderID;
  final bool isWeb;
  final String? route;
  const MyApp({super.key, this.orderID, required this.isWeb, this.route});

  @override
  State<MyApp> createState() => _MyAppState();
}

Future<String?> initDynamicLinks() async {
  final appLinks = AppLinks();
  final uri = await appLinks.getInitialLink();
  return uri?.path;
}

class _MyAppState extends State<MyApp> {
  late Future<void> _initAppFuture;

  @override
  void initState() {
    super.initState();
    // ✅ تحميل كل إعدادات التطبيق قبل إخفاء الـ Native Splash
    _initAppFuture = _loadAppData();
  }

  Future<void> _loadAppData() async {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    await splashProvider.initSharedData();
    cartProvider.getCartData();

    final configModel = await splashProvider.initConfig(
      context,
      source: DataSourceEnum.local,
    );
    if (configModel != null) {
      splashProvider.getDeliveryInfo();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn()) {
        authProvider.updateToken();
      }
    }
    _onRemoveLoader();
  }

  void _onRemoveLoader() {
    final preloader = html.document.querySelector('.preloader');
    if (preloader != null) {
      Future.delayed(const Duration(seconds: 1)).then((_) {
        preloader.remove();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Locale> locals = [];
    for (var language in AppConstants.languages) {
      locals.add(Locale(language.languageCode!, language.countryCode));
    }

    return FutureBuilder(
      future: _initAppFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // ✅ إخفاء الـ Native Splash فور اكتمال التحميل والتنقل للشاشة الرئيسية مباشرة
          FlutterNativeSplash.remove();
        }

        return Consumer<SplashProvider>(
          builder: (context, splashProvider, child) {
            return MaterialApp.router(
              routerConfig: RouteHelper.goRoutes,
              debugShowCheckedModeBanner: false,
              title:
                  splashProvider.configModel?.ecommerceName ??
                  AppConstants.appName,
              theme: Provider.of<ThemeProvider>(context).darkTheme
                  ? dark
                  : light,
              locale: Provider.of<LocalizationProvider>(context).locale,
              localizationsDelegates: const [
                AppLocalization.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: locals,
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.unknown,
                },
              ),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.sizeOf(context).width < 380 ? 0.8 : 1,
                    ),
                  ),
                  child: Scaffold(
                    body: SafeArea(
                      top: false,
                      bottom: !kIsWeb && Platform.isAndroid,
                      child: Stack(
                        children: [
                          child ?? const SizedBox.shrink(),
                          if (ResponsiveHelper.isDesktop(context))
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 50,
                                    horizontal: 20,
                                  ),
                                  child: ThirdPartyChatWidget(
                                    configModel: splashProvider.configModel!,
                                  ),
                                ),
                              ),
                            ),
                          if (kIsWeb &&
                              splashProvider.configModel!.cookiesManagement !=
                                  null &&
                              splashProvider
                                  .configModel!
                                  .cookiesManagement!
                                  .status! &&
                              !splashProvider.getAcceptCookiesStatus(
                                splashProvider
                                    .configModel!
                                    .cookiesManagement!
                                    .content,
                              ) &&
                              splashProvider.cookiesShow)
                            const Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: CookiesWidget(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class Get {
  static BuildContext? get context => navigatorKey.currentContext;
  static NavigatorState? get navigator => navigatorKey.currentState;
}
