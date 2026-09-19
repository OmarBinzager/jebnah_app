import 'package:dio/dio.dart';
import 'package:jebnah/features/brand/providers/brand_provider.dart';
import 'package:jebnah/features/home/providers/seller_provider.dart';
import 'common/reposotories/data_sync_repo.dart';
import 'data/datasource/local/cache_response.dart';
import 'features/auth/domain/reposotories/auth_repo.dart';
import 'features/auth/providers/facebook_login_provider.dart';
import 'features/auth/providers/verification_provider.dart';
import 'features/home/domain/reposotories/banner_repo.dart';
import 'features/brand/domain/reposotories/brand_repo.dart';
import 'features/home/domain/reposotories/seller_repo.dart';
import 'common/reposotories/cart_repo.dart';
import 'features/category/domain/reposotories/category_repo.dart';
import 'features/chat/domain/reposotories/chat_repo.dart';
import 'features/coupon/domain/reposotories/coupon_repo.dart';
import 'common/reposotories/language_repo.dart';
import 'features/address/domain/reposotories/location_repo.dart';
import 'features/notification/domain/reposotories/notification_repo.dart';
import 'features/onboarding/domain/reposotories/onboarding_repo.dart';
import 'features/order/domain/reposotories/order_repo.dart';
import 'common/reposotories/product_repo.dart';
import 'features/order/providers/image_note_provider.dart';
import 'features/order_track/domain/repositories/time_repo.dart';
import 'features/order_track/providers/tracker_provider.dart';
import 'features/profile/domain/reposotories/profile_repo.dart';
import 'features/review/providers/review_provider.dart';
import 'features/search/domain/reposotories/search_repo.dart';
import 'features/splash/domain/reposotories/splash_repo.dart';
import 'features/wallet_and_loyalty/domain/reposotories/wallet_repo.dart';
import 'features/wishlist/domain/reposotories/wishlist_repo.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/banner_provider.dart';
import 'common/providers/cart_provider.dart';
import 'features/category/providers/category_provider.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/coupon/providers/coupon_provider.dart';
import 'features/home/providers/flash_deal_provider.dart';
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
import 'utill/app_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/datasource/remote/dio/dio_client.dart';
import 'data/datasource/remote/dio/logging_interceptor.dart';
import 'common/reposotories/news_letter_repo.dart';

final sl = GetIt.instance;
final database = AppDatabase();

Future<void> init() async {
  // Core
  sl.registerLazySingleton(
    () => DioClient(
      AppConstants.baseUrl,
      sl(),
      loggingInterceptor: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton(
    () => DataSyncRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => SplashRepo(sharedPreferences: sl(), dioClient: sl()),
  );
  sl.registerLazySingleton(() => OnBoardingRepo(dioClient: sl()));
  sl.registerLazySingleton(
    () => CategoryRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => ProductRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => SearchRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => ChatRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => AuthRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(() => CartRepo(sharedPreferences: sl()));
  sl.registerLazySingleton(() => CouponRepo(dioClient: sl()));
  sl.registerLazySingleton(
    () => OrderRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => LocationRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => ProfileRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => BannerRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => BrandRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => SellerRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(() => NotificationRepo(dioClient: sl()));
  sl.registerLazySingleton(() => LanguageRepo(dioClient: sl()));
  sl.registerLazySingleton(() => NewsLetterRepo(dioClient: sl()));
  sl.registerLazySingleton(
    () => WishListRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => WalletRepo(dioClient: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(
    () => TrackerRepo(dioClient: sl(), sharedPreferences: sl()),
  );

  // Provider
  // sl.registerLazySingleton(() => DataSyncProvider());
  sl.registerFactory(() => ThemeProvider(sharedPreferences: sl()));
  sl.registerFactory(
    () => LocalizationProvider(
      dioClient: sl(),
      sharedPreferences: sl(),
      languageRepo: sl(),
    ),
  );
  sl.registerFactory(() => SplashProvider(splashRepo: sl()));
  sl.registerFactory(() => OnBoardingProvider(onboardingRepo: sl()));
  sl.registerFactory(
    () => CategoryProvider(
      categoryRepo: sl(),
      productRepo: sl(),
      searchRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductProvider(productRepo: sl(), searchRepo: sl()),
  );
  sl.registerFactory(() => SearchProvider(searchRepo: sl()));
  sl.registerFactory(
    () => ChatProvider(chatRepo: sl(), notificationRepo: sl()),
  );
  sl.registerFactory(() => AuthProvider(authRepo: sl()));
  sl.registerFactory(() => CartProvider(cartRepo: sl()));
  sl.registerFactory(() => CouponProvider(couponRepo: sl()));
  sl.registerFactory(
    () => LocationProvider(locationRepo: sl(), sharedPreferences: sl()),
  );
  sl.registerFactory(() => ProfileProvider(profileRepo: sl()));
  sl.registerFactory(
    () => OrderProvider(orderRepo: sl(), sharedPreferences: sl()),
  );
  sl.registerFactory(() => BannerProvider(bannerRepo: sl()));
  sl.registerFactory(() => BrandProvider(brandRepo: sl()));
  sl.registerFactory(() => SellerProvider(sellerRepo: sl()));
  sl.registerFactory(() => NotificationProvider(notificationRepo: sl()));
  sl.registerFactory(() => LanguageProvider(languageRepo: sl()));
  sl.registerFactory(() => NewsLetterProvider(newsLetterRepo: sl()));
  sl.registerFactory(() => WishListProvider(wishListRepo: sl()));
  sl.registerFactory(() => WalletAndLoyaltyProvider(walletRepo: sl()));
  sl.registerFactory(() => FlashDealProvider(productRepo: sl()));
  sl.registerFactory(() => ReviewProvider(orderRepo: sl()));
  sl.registerFactory(() => VerificationProvider(authRepo: sl()));
  sl.registerFactory(() => OrderImageNoteProvider());
  sl.registerFactory(() => TrackerProvider(trackerRepo: sl()));
  sl.registerFactory(() => FacebookLoginProvider());

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => LoggingInterceptor());
}
