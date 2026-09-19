import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'common/enums/app_mode_enum.dart';
import 'common/enums/data_source_enum.dart';
import 'features/auth/providers/verification_provider.dart';
import 'features/home/providers/flash_deal_provider.dart';
import 'features/order/providers/image_note_provider.dart';
import 'features/order_track/providers/tracker_provider.dart';
import 'features/review/providers/review_provider.dart';

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
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCDmxgOAjPs4xSEEgaVIDCd_FXCQyFWg-s",
            authDomain: "jebnah.firebaseapp.com",
            projectId: "jebnah",
            storageBucket: "jebnah.firebasestorage.app",
            messagingSenderId: "1090280767907",
            appId: "1:1090280767907:web:8703626713a04f7b139a16",
          ),
        );
      } else if (Platform.isAndroid) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCDmxgOAjPs4xSEEgaVIDCd_FXCQyFWg-s",
            appId: "1:1090280767907:android:8703626713a04f7b139a16",
            messagingSenderId: "1090280767907",
            projectId: "jebnah",
            storageBucket: "jebnah.firebasestorage.app",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Firebase: ${e.toString()}');
    }
  }

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
    if (defaultTargetPlatform == TargetPlatform.android) {
      FirebaseMessaging.instance.requestPermission();
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

    splashProvider.initSharedData();
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
