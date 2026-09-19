import 'dart:convert';
import '../features/brand/screens/all_brands_screen.dart';
import '../features/order/widgets/order_map_info_widget.dart';
import '../features/product/screens/preview_screen.dart';
import '../features/wallet_and_loyalty/screens/game_screen.dart';
import '../helper/responsive_helper.dart';
import '../main.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../common/models/config_model.dart';
import '../common/models/place_order_model.dart';
import '../features/address/domain/models/address_model.dart';
import '../features/auth/screens/otp_registration_screen.dart';
import '../features/auth/screens/send_otp_screen.dart';
import '../features/order/domain/models/order_model.dart';
import '../common/enums/html_type_enum.dart';
import '../features/order_track/screens/track_map_screen.dart';
import '../helper/maintenance_helper.dart';
import '../features/splash/providers/splash_provider.dart';
import '../features/address/screens/add_new_address_screen.dart';
import '../features/address/screens/address_list_screen.dart';
import '../features/address/screens/select_location_screen.dart';
import '../features/auth/screens/create_account_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/maintainance/screens/maintainance_screen.dart';
import '../features/cart/screens/cart_screen.dart';
import '../features/category/screens/all_categories_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/checkout/screens/checkout_screen.dart';
import '../features/checkout/screens/order_success_screen.dart';
import '../features/payment/screens/payment_screen.dart';
import '../features/payment/screens/web_payment_screen.dart';
import '../features/support/screens/support_screen.dart';
import '../features/coupon/screens/coupon_screen.dart';
import '../features/auth/screens/create_new_password_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/verification_screen.dart';
import '../features/home/screens/home_item_screen.dart';
import '../features/html/screens/html_viewer_screen.dart';
import '../features/wallet_and_loyalty/screens/loyalty_screen.dart';
import '../features/menu/screens/menu_screen.dart';
import '../features/notification/screens/notification_screen.dart';
import '../features/onboarding/screens/on_boarding_screen.dart';
import '../features/order/screens/order_list_screen.dart';
import '../features/order/screens/order_details_screen.dart';
import '../features/order/screens/order_search_screen.dart';
import '../features/order_track/screens/track_order_screen.dart';
import '../features/product/screens/category_product_screen.dart';
import '../features/product/screens/product_image_screen.dart';
import '../features/product/screens/product_details_screen.dart';
import '../features/profile/screens/profile_edit_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/refer_and_earn/screens/refer_and_earn_screen.dart';
import '../features/search/screens/search_result_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/menu/screens/setting_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/update/screens/update_screen.dart';
import '../features/wallet_and_loyalty/screens/wallet_screen.dart';
import '../features/wishlist/screens/wishlist_screen.dart';
import 'package:provider/provider.dart';

enum RouteAction { push, pushReplacement, pushNamedAndRemoveUntil }

class RouteHelper {
  static const String splash = '/splash';
  static const String orderDetails = '/order-details';
  static const String onBoarding = '/on-boarding';
  static const String menu = '/';
  static const String login = '/login';
  static const String favorite = '/favorite';
  static const String forgetPassword = '/forget-password';
  static const String verification = '/verification';
  static const String createAccount = '/create-account';
  static const String resetPassword = '/reset-password';
  static const String updateAddress = '/update-address';
  static const String selectLocation = '/select-location';
  static const String orderSuccessful = '/order-complete';
  static const String payment = '/payment';
  static const String checkout = '/checkout';
  static const String notification = '/notification';
  static const String trackOrder = '/track-order';
  static const String trackMapScreen = '/track-map';
  static const String categoryProducts = '/category-products';
  static const String productDetails = '/product-details';
  static const String relatedProductsUri = '/api/v1/products/related-products/';
  static const String productImages = '/product-images';
  static const String profile = '/profile';
  static const String searchProduct = '/search-product';
  static const String profileEdit = '/profile-edit';
  static const String searchResult = '/search-result';
  static const String cart = '/cart';
  static const String categories = '/categories';
  static const String profileMenus = '/menus';
  static const String orderListScreen = '/order-list';
  static const String address = '/address';
  static const String coupon = '/coupon';
  static const String chatScreen = '/chat-screen';
  static const String settings = '/settings';
  static const String termsScreen = '/terms';
  static const String policyScreen = '/privacy-policy';
  static const String aboutUsScreen = '/about-us';
  static const String faqScreen = '/faqScreen';
  static const String homeItem = '/home-item';
  static const String maintenance = '/maintenance';
  static const String contactScreen = '/contact';
  static const String update = '/update';
  static const String addAddressScreen = '/add-address';
  static const String orderWebPayment = '/order-web-payment';
  static const String wallet = '/wallet';
  static const String referAndEarn = '/referAndEarn';
  static const String returnPolicyScreen = '/return-policy';
  static const String refundPolicyScreen = '/refund-policy';
  static const String cancellationPolicyScreen = '/cancellation-policy';
  static const String orderSearchScreen = '/order-search';
  static const String loyaltyScreen = '/loyalty';
  static const String gameScreen = '/game';

  static const String sendOtp = '/send-otp-verification';
  static const String otpRegistration = '/otp-registration';
  static const String imagePreview = '/image_preview';
  static const String orderMapInfo = '/order_map_info';

  // Static getter methods for routes
  static String getMainRoute({RouteAction? action}) {
    return _navigateRoute(menu, route: action);
  }

  static String getLoginRoute({RouteAction? action}) =>
      _navigateRoute(login, route: action);
  static String getTermsRoute({RouteAction? action}) =>
      _navigateRoute(termsScreen, route: action);
  static String getPolicyRoute({RouteAction? action}) =>
      _navigateRoute(policyScreen, route: action);
  static String getAboutUsRoute({RouteAction? action}) =>
      _navigateRoute(aboutUsScreen, route: action);
  static String getFaqRoute({RouteAction? action}) =>
      _navigateRoute(faqScreen, route: action);
  static String getUpdateRoute({RouteAction? action}) =>
      _navigateRoute(update, route: action);
  static String getSelectLocationRoute({RouteAction? action}) =>
      _navigateRoute(selectLocation, route: action);
  static String getSendOtpScreen({RouteAction? action}) =>
      _navigateRoute(sendOtp, route: action);
  static String getOtpRegistration(
    String? tempToken,
    String userInput, {
    String? userName,
    RouteAction? action,
  }) {
    String data = '';
    if (tempToken?.isNotEmpty ?? false) {
      data = Uri.encodeComponent(jsonEncode(tempToken));
    }
    String input = Uri.encodeComponent(jsonEncode(userInput));
    String name = Uri.encodeComponent(jsonEncode(userName ?? ''));
    return _navigateRoute(
      '$otpRegistration?tempToken=$data&input=$input&userName=$name',
      route: action,
    );
  }

  static String getSplashRoute({RouteAction? action}) =>
      _navigateRoute(splash, route: action);
  static String getOrderDetailsRoute(
    String? id, {
    String? phoneNumber,
    RouteAction? action,
    String? token,
    OrderModel? orderModel,
  }) {
    String? data = orderModel != null
        ? base64Url.encode(utf8.encode(jsonEncode(orderModel.toJson())))
        : null;
    return _navigateRoute(
      '$orderDetails?id=$id&phone=${Uri.encodeComponent('$phoneNumber')}&order_details=$data',
      route: action,
    );
  }

  static String getVerifyRoute(
    String userInput,
    String fromPage, {
    String? session,
    RouteAction? action,
  }) {
    String data = Uri.encodeComponent(jsonEncode(userInput));
    String authSession = base64Url.encode(utf8.encode(session ?? ''));
    return _navigateRoute(
      '$verification?page=$fromPage&userInput=$data&session=$authSession',
      route: action,
    );
  }

  static String getNewPassRoute(
    String? userInput,
    String token, {
    RouteAction? action,
  }) => _navigateRoute(
    '$resetPassword?email=${Uri.encodeComponent('$userInput')}&token=$token',
    route: action,
  );
  static String getAddAddressRoute(
    String page,
    String action,
    AddressModel addressModel, {
    RouteAction? routeAction,
  }) {
    String data = base64Url.encode(
      utf8.encode(jsonEncode(addressModel.toJson())),
    );
    return _navigateRoute(
      '$addAddressScreen?page=$page&action=$action&address=$data',
      route: routeAction,
    );
  }

  static String getUpdateAddressRoute(
    AddressModel addressModel, {
    RouteAction? action,
  }) {
    String data = base64Url.encode(
      utf8.encode(jsonEncode(addressModel.toJson())),
    );
    return _navigateRoute('$updateAddress?address=$data', route: action);
  }

  static String getPaymentRoute({
    String? id = '',
    String? url,
    RouteAction? action,
    PlaceOrderModel? placeOrderBody,
  }) {
    String uri = url != null
        ? Uri.encodeComponent(base64Encode(utf8.encode(url)))
        : 'null';
    String data = placeOrderBody != null
        ? base64Encode(utf8.encode(jsonEncode(placeOrderBody.toJson())))
        : '';
    return _navigateRoute(
      '$payment?id=$id&uri=$uri&place_order=$data',
      route: action,
    );
  }

  static String getCheckoutRoute(
    double amount,
    double? tax,
    double? discount,
    double? couponDiscount,
    String? type,
    String code,
    String freeDelivery,
    double weight, {
    RouteAction? action,
  }) {
    String fd = freeDelivery.isNotEmpty
        ? base64Encode(utf8.encode(freeDelivery))
        : '';
    return _navigateRoute(
      '$checkout?amount=${base64Encode(utf8.encode('$amount'))}&tax=${base64Encode(utf8.encode('$tax'))}&discount=${base64Encode(utf8.encode('$discount'))}&couponDiscount=${base64Encode(utf8.encode('$couponDiscount'))}&type=$type&code=${base64Encode(utf8.encode(code))}&c-type=$fd&weight=${base64Encode(utf8.encode('$weight'))}',
      route: action,
    );
  }

  static String getOrderTrackingRoute(
    int? id,
    String? phoneNumber, {
    RouteAction? action,
  }) => _navigateRoute(
    '$trackOrder?id=$id&phone=${Uri.encodeComponent('$phoneNumber')}',
    route: action,
  );
  static String getTrackMapScreen({
    OrderModel? order,
    int? orderId,
    int? deliverymanId,
    RouteAction? action,
  }) {
    String data = base64Url.encode(utf8.encode(jsonEncode(order?.toJson())));
    return _navigateRoute(
      '$trackMapScreen?data=$data&deliveryman=$deliverymanId&order=$orderId',
      route: action,
    );
  }

  static String getCategoryProductsRoute({
    required String categoryId,
    String? categoryName,
    RouteAction? action,
  }) => _navigateRoute(
    '$categoryProducts?category_id=$categoryId&category_name=${Uri.encodeFull(categoryName ?? '')}',
    route: action,
  );
  static String getProductDetailsRoute({
    required int? productId,
    bool formSearch = false,
    RouteAction? action,
  }) {
    String fromSearch = jsonEncode(formSearch);
    return _navigateRoute(
      '$productDetails?product_id=$productId&search=$fromSearch',
      route: action,
    );
  }

  static String getProductImagesRoute(
    String? name,
    String images,
    String baseUrl, {
    RouteAction? action,
  }) => _navigateRoute(
    '$productImages?name=$name&images=$images&base_url=${Uri.encodeComponent(baseUrl)}',
    route: action,
  );
  static String getProfileEditRoute({RouteAction? action}) =>
      _navigateRoute(profileEdit, route: action);
  static String getHomeItemRoute(String productType, {RouteAction? action}) =>
      _navigateRoute('$homeItem?item=$productType', route: action);
  static String getMaintenanceRoute({RouteAction? action}) =>
      _navigateRoute(maintenance, route: action);
  static String getSearchResultRoute(String text, {RouteAction? action}) {
    List<int> encoded = utf8.encode(text);
    String data = base64Encode(encoded);
    return _navigateRoute('$searchResult?text=$data', route: action);
  }

  static String getChatRoute({
    required String orderId,
    required String userName,
    required String profileImage,
    required String senderType,
    bool isAppBar = false,
    RouteAction? action,
  }) => _navigateRoute(
    '$chatScreen?order_id=$orderId&name=$userName&image=$profileImage&type=$senderType&show_appbar=$isAppBar',
    route: action,
  );
  static String getContactRoute({RouteAction? action}) =>
      _navigateRoute(contactScreen, route: action);
  static String getFavoriteRoute({RouteAction? action}) =>
      _navigateRoute(favorite, route: action);
  static String getWalletRoute({
    String? token,
    String? status,
    RouteAction? action,
  }) => _navigateRoute('$wallet?token=$token&flag=$status', route: action);
  static String getReferAndEarnRoute({RouteAction? action}) =>
      _navigateRoute(referAndEarn, route: action);
  static String getReturnPolicyRoute({RouteAction? action}) =>
      _navigateRoute(returnPolicyScreen, route: action);
  static String getCancellationPolicyRoute({RouteAction? action}) =>
      _navigateRoute(cancellationPolicyScreen, route: action);
  static String getRefundPolicyRoute({RouteAction? action}) =>
      _navigateRoute(refundPolicyScreen, route: action);
  static String getLoyaltyScreen({RouteAction? action}) =>
      _navigateRoute(loyaltyScreen, route: action);

  static String getGameScreen({RouteAction? action}) =>
      _navigateRoute(gameScreen, route: action);

  static String getCreateAccount({RouteAction? action}) =>
      _navigateRoute(createAccount, route: action);
  static String getCartScreen({RouteAction? action}) =>
      _navigateRoute(cart, route: action);
  static String getSearchProduct({RouteAction? action}) =>
      _navigateRoute(searchProduct, route: action);
  static String getProfileMenus({RouteAction? action}) =>
      _navigateRoute(profileMenus, route: action);
  static String getProfileScreen({RouteAction? action}) =>
      _navigateRoute(profile, route: action);
  static String getOnboardingScreen({RouteAction? action}) =>
      _navigateRoute(onBoarding, route: action);
  static String getNotificationScreen({RouteAction? action}) =>
      _navigateRoute(notification, route: action);
  static String getAddressListScreen({RouteAction? action}) =>
      _navigateRoute(address, route: action);
  static String getOrderListScreen({RouteAction? action}) =>
      _navigateRoute(orderListScreen, route: action);
  static String getAllCategoryScreen({RouteAction? action}) =>
      _navigateRoute(categories, route: action);
  static String getForgetPasswordScreen({RouteAction? action}) =>
      _navigateRoute(forgetPassword, route: action);
  static String getImagePreviewScreen(
    List<String> images,
    int index, {
    RouteAction? action,
  }) {
    String imageList = jsonEncode(images);
    return _navigateRoute(
      '$imagePreview?images=$imageList&index=$index',
      route: action,
    );
  }

  static String getOrderMapInfoRoute(
    DeliveryAddress? deliveryAddress, {
    RouteAction? action,
  }) {
    String data = base64Url.encode(
      utf8.encode(jsonEncode(deliveryAddress?.toJson())),
    );
    return _navigateRoute(
      '$orderMapInfo?delivery_address=$data',
      route: action,
    );
  }

  static String getOrderSearchRoute({RouteAction? action}) =>
      _navigateRoute(orderSearchScreen, route: action);
  static String getCouponRoute({RouteAction? action}) =>
      _navigateRoute(coupon, route: action);
  static String getOrderSuccessRoute(
    String orderId,
    String? status, {
    RouteAction? action,
  }) {
    return _navigateRoute(
      '$orderSuccessful?id=$orderId&status=$status',
      route: action,
    );
  }

  static const String brandDetails = '/brand-details';
  static const String allBrands = '/brands';
  static const String brandProductsUri = '/products';
  static String getAllBrandsScreen({RouteAction? action}) =>
      _navigateRoute(allBrands, route: action);

  ///Routes Declear here.
  static final goRoutes = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: ResponsiveHelper.isMobilePhone()
        ? getSplashRoute()
        : getMainRoute(),
    errorBuilder: (context, state) =>
        _routeHandler(context, child: const MenuScreen()),
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) =>
            _routeHandler(context, child: const SplashScreen()),
      ),
      GoRoute(
        path: orderDetails,
        builder: (context, state) {
          int? orderId = int.tryParse(state.uri.queryParameters['id'] ?? '');
          String? phone = Uri.decodeComponent(
            state.uri.queryParameters['phone'] ?? '',
          );
          String? token = state.uri.queryParameters['token'];
          String? flag = state.uri.queryParameters['flag'];

          OrderModel? orderModel =
              state.uri.queryParameters['order_details'] == 'null'
              ? null
              : OrderModel.fromJson(
                  jsonDecode(
                    utf8.decode(
                      base64Decode(
                        '${state.uri.queryParameters['order_details']?.replaceAll(' ', '+')}',
                      ),
                    ),
                  ),
                );

          return _routeHandler(
            context,
            child: OrderDetailsScreen(
              orderId: orderId,
              orderModel: orderModel,
              phoneNumber: phone,
              token: token,
              flag: flag,
            ),
          );
        },
      ),
      GoRoute(
        path: onBoarding,
        builder: (context, state) =>
            _routeHandler(context, child: OnBoardingScreen()),
      ),
      GoRoute(
        path: menu,
        builder: (context, state) {
          bool? isLoad = jsonDecode(
            state.uri.queryParameters['is_load'] ?? 'true',
          );
          bool? fromInto = jsonDecode(
            state.uri.queryParameters['from_intro'] ?? 'false',
          );
          return _routeHandler(
            context,
            child: MenuScreen(
              isReload: isLoad ?? true,
              fromIntro: fromInto ?? false,
            ),
          );
        },
      ),
      GoRoute(
        path: login,
        builder: (context, state) =>
            _routeHandler(context, child: const LoginScreen()),
      ),
      GoRoute(
        path: forgetPassword,
        builder: (context, state) =>
            _routeHandler(context, child: const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: sendOtp,
        builder: (context, state) =>
            _routeHandler(context, child: const SendOtpScreen()),
      ),
      GoRoute(
        path: otpRegistration,
        builder: (context, state) {
          String tempTokenJson = state.uri.queryParameters['tempToken'] ?? '';
          String inputJson = state.uri.queryParameters['input'] ?? '';
          String userNameJson = state.uri.queryParameters['userName'] ?? '';

          String? tempToken;
          String? input;
          String? userName;

          if (tempTokenJson.isNotEmpty) {
            tempToken = jsonDecode(Uri.decodeComponent(tempTokenJson));
          }

          if (inputJson.isNotEmpty) {
            input = jsonDecode(Uri.decodeComponent(inputJson));
          }

          if (userNameJson.isNotEmpty) {
            userName = jsonDecode(Uri.decodeComponent(userNameJson));
          }

          return _routeHandler(
            context,
            child: OtpRegistrationScreen(
              tempToken: tempToken ?? '',
              userInput: input ?? '',
              userName: userName,
            ),
          );
        },
      ),
      GoRoute(
        path: verification,
        builder: (context, state) {
          String page = state.uri.queryParameters['page'] ?? '';
          String userInputJson = state.uri.queryParameters['userInput'] ?? '';
          String sessionStr = state.uri.queryParameters['session'] ?? 'null';

          String userInput = jsonDecode(userInputJson);

          return _routeHandler(
            context,
            child: VerificationScreen(
              fromPage: page,
              userInput: userInput,
              session: sessionStr == 'null'
                  ? null
                  : utf8.decode(
                      base64Url.decode(sessionStr.replaceAll(' ', '+')),
                    ),
            ),
          );
        },
      ),
      GoRoute(
        path: createAccount,
        builder: (context, state) => _routeHandler(
          context,
          child: CreateAccountScreen(
            referralCode: state.uri.queryParameters['referral_code'],
          ),
        ),
      ),
      GoRoute(
        path: resetPassword,
        builder: (context, state) {
          return _routeHandler(
            context,
            child: CreateNewPasswordScreen(
              userInput: Uri.decodeComponent(
                state.uri.queryParameters['email'] ?? '',
              ),
              resetToken: state.uri.queryParameters['token'] ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: updateAddress,
        builder: (context, state) {
          String decoded = utf8.decode(
            base64Url.decode(
              state.uri.queryParameters['address']?.replaceAll(' ', '+') ?? '',
            ),
          );
          return _routeHandler(
            context,
            child: AddNewAddressScreen(
              isEnableUpdate: true,
              fromCheckout: false,
              address: AddressModel.fromJson(jsonDecode(decoded)),
            ),
          );
        },
      ),
      GoRoute(
        path: selectLocation,
        builder: (context, state) {
          return _routeHandler(context, child: SelectLocationScreen());
        },
      ),
      GoRoute(
        path: orderSuccessful,
        builder: (context, state) {
          int status =
              (state.uri.queryParameters['status'] == 'success' ||
                  state.uri.queryParameters['status'] == 'payment-success')
              ? 0
              : (state.uri.queryParameters['status'] == 'fail' ||
                    state.uri.queryParameters['status'] == 'payment-fail')
              ? 1
              : 2;
          return _routeHandler(
            context,
            child: OrderSuccessScreen(
              orderID: state.uri.queryParameters['id'] ?? '',
              status: status,
            ),
          );
        },
      ),
      GoRoute(
        path: orderWebPayment,
        builder: (context, state) {
          return _routeHandler(
            context,
            child: WebPaymentScreen(
              token: state.uri.queryParameters['token'] ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: payment,
        builder: (context, state) {
          return _routeHandler(
            context,
            child: PaymentScreen(
              orderId: int.tryParse(state.uri.queryParameters['id'] ?? ''),
              url: Uri.decodeComponent(
                utf8.decode(
                  base64Decode(state.uri.queryParameters['uri'] ?? ''),
                ),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: checkout,
        builder: (context, state) {
          return _routeHandler(
            context,
            child: CheckoutScreen(
              orderType: state.uri.queryParameters['type'] ?? '',
              tax: double.parse(
                utf8.decode(
                  base64Decode(state.uri.queryParameters['tax'] ?? ''),
                ),
              ),
              discount: double.parse(
                utf8.decode(
                  base64Decode(state.uri.queryParameters['discount'] ?? ''),
                ),
              ),
              couponDiscount: double.parse(
                utf8.decode(
                  base64Decode(
                    state.uri.queryParameters['couponDiscount'] ?? '',
                  ),
                ),
              ),
              amount: double.parse(
                utf8.decode(
                  base64Decode(state.uri.queryParameters['amount'] ?? ''),
                ),
              ),
              couponCode: utf8.decode(
                base64Decode(state.uri.queryParameters['code'] ?? ''),
              ),
              freeDeliveryType: utf8.decode(
                base64Decode(state.uri.queryParameters['c-type'] ?? ''),
              ),
              weight: double.parse(
                utf8.decode(
                  base64Decode(state.uri.queryParameters['weight'] ?? ''),
                ),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: notification,
        builder: (context, state) =>
            _routeHandler(context, child: const NotificationScreen()),
      ),
      GoRoute(
        path: trackOrder,
        builder: (context, state) {
          return _routeHandler(
            context,
            child: TrackOrderScreen(
              orderID: state.uri.queryParameters['id'] ?? '',
              phone: Uri.decodeComponent(
                state.uri.queryParameters['phone'] ?? '',
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: trackMapScreen,
        builder: (context, state) {
          OrderModel? order;
          String decoded = utf8.decode(
            base64Url.decode(
              state.uri.queryParameters['data']?.replaceAll(' ', '+') ?? '',
            ),
          );
          order = OrderModel.fromJson(jsonDecode(decoded));

          return _routeHandler(
            context,
            child: TrackMapScreen(
              orderId: int.tryParse(state.uri.queryParameters['order'] ?? ''),
              deliverymanId: int.tryParse(
                state.uri.queryParameters['deliveryman'] ?? '',
              ),
              order: order,
            ),
          );
        },
      ),
      GoRoute(
        path: categoryProducts,
        builder: (context, state) => _routeHandler(
          context,
          child: CategoryProductScreen(
            categoryId: state.uri.queryParameters['category_id'] ?? '',
            categoryName: state.uri.queryParameters['category_name'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: productDetails,
        builder: (context, state) {
          bool? fromSearch = jsonDecode(
            state.uri.queryParameters['search'] ?? 'false',
          );

          return _routeHandler(
            context,
            child: ProductDetailsScreen(
              productId: state.uri.queryParameters['product_id'],
              fromSearch: fromSearch,
            ),
          );
        },
      ),
      GoRoute(
        path: productImages,
        builder: (context, state) {
          return _routeHandler(
            context,
            child: ProductImageScreen(
              title: state.uri.queryParameters['name'],
              baseUrl: Uri.decodeComponent(
                state.uri.queryParameters['base_url'] ?? '',
              ),
              imageList: List<String>.from(
                (jsonDecode(state.uri.queryParameters['images'] ?? '[]')
                    as List<dynamic>),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: profile,
        builder: (context, state) =>
            _routeHandler(context, child: const ProfileScreen()),
      ),
      GoRoute(
        path: searchProduct,
        builder: (context, state) =>
            _routeHandler(context, child: const SearchScreen()),
      ),
      GoRoute(
        path: profileEdit,
        builder: (context, state) =>
            _routeHandler(context, child: const ProfileEditScreen()),
      ),
      GoRoute(
        path: searchResult,
        builder: (context, state) {
          List<int> decode = base64Decode(
            state.uri.queryParameters['text'] ?? '',
          );
          String data = utf8.decode(decode);
          return _routeHandler(
            context,
            child: SearchResultScreen(searchString: data),
          );
        },
      ),
      GoRoute(
        path: cart,
        builder: (context, state) =>
            _routeHandler(context, child: const CartScreen()),
        redirect: (ctx, state) {
          return _redirectUrl(ctx, state, 2);
        },
      ),
      GoRoute(
        path: categories,
        builder: (context, state) =>
            _routeHandler(context, child: const AllCategoriesScreen()),
      ),
      GoRoute(
        path: allBrands,
        builder: (context, state) =>
            _routeHandler(context, child: const AllBrandsScreen()),
      ),
      GoRoute(
        path: profileMenus,
        builder: (context, state) =>
            _routeHandler(context, child: const MenuWidget()),
      ),
      GoRoute(
        path: orderListScreen,
        builder: (context, state) =>
            _routeHandler(context, child: const OrderListScreen()),
        redirect: (ctx, state) {
          return _redirectUrl(ctx, state, 4);
        },
      ),
      GoRoute(
        path: address,
        builder: (context, state) =>
            _routeHandler(context, child: const AddressListScreen()),
        redirect: (context, state) {
          return _redirectUrl(context, state, 6);
        },
      ),
      GoRoute(
        path: coupon,
        builder: (context, state) =>
            _routeHandler(context, child: const CouponScreen()),
        redirect: (context, state) {
          return _redirectUrl(context, state, 7);
        },
      ),
      GoRoute(
        path: chatScreen,
        builder: (context, state) {
          bool isAppbar = state.uri.queryParameters['show_appbar'] == 'true';
          return _routeHandler(
            context,
            child: ChatScreen(
              orderId: state.uri.queryParameters['order_id'] ?? '',
              userName: state.uri.queryParameters['name'] ?? '',
              senderType: state.uri.queryParameters['type'] ?? '',
              profileImage: state.uri.queryParameters['image'] ?? '',
              isAppBar: isAppbar,
            ),
          );
        },
        redirect: (context, state) {
          return _redirectUrl(context, state, 8);
        },
      ),
      GoRoute(
        path: settings,
        builder: (context, state) =>
            _routeHandler(context, child: const SettingsScreen()),
      ),
      GoRoute(
        path: termsScreen,
        builder: (context, state) => _routeHandler(
          context,
          child: const HtmlViewerScreen(htmlType: HtmlType.termsAndCondition),
        ),
        redirect: (ctx, state) {
          return _redirectUrl(ctx, state, 13);
        },
      ),
      GoRoute(
        path: policyScreen,
        builder: (context, state) => _routeHandler(
          context,
          child: const HtmlViewerScreen(htmlType: HtmlType.privacyPolicy),
        ),
        redirect: (ctx, state) {
          return _redirectUrl(ctx, state, 14);
        },
      ),
      GoRoute(
        path: aboutUsScreen,
        builder: (context, state) => _routeHandler(
          context,
          child: const HtmlViewerScreen(htmlType: HtmlType.aboutUs),
        ),
        redirect: (ctx, state) {
          return _redirectUrl(ctx, state, 15);
        },
      ),
      GoRoute(
        path: faqScreen,
        builder: (context, state) => _routeHandler(
          context,
          child: const HtmlViewerScreen(htmlType: HtmlType.faq),
        ),
        redirect: (ctx, state) {
          return _redirectUrl(ctx, state, 19);
        },
      ),
      GoRoute(
        path: homeItem,
        builder: (context, state) => _routeHandler(
          context,
          child: HomeItemScreen(
            productType: state.uri.queryParameters['item'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: maintenance,
        builder: (context, state) =>
            _routeHandler(context, child: const MaintenanceScreen()),
      ),
      GoRoute(
        path: contactScreen,
        builder: (context, state) =>
            _routeHandler(context, child: const SupportScreen()),
      ),
      GoRoute(
        path: update,
        builder: (context, state) =>
            _routeHandler(context, child: const UpdateScreen()),
      ),
      GoRoute(
        path: addAddressScreen,
        builder: (context, state) {
          bool isUpdate = state.uri.queryParameters['action'] == 'update';
          AddressModel? addressModel;
          if (isUpdate) {
            String decoded = utf8.decode(
              base64Url.decode(
                state.uri.queryParameters['address']?.replaceAll(' ', '+') ??
                    '',
              ),
            );
            addressModel = AddressModel.fromJson(jsonDecode(decoded));
          }
          return _routeHandler(
            context,
            child: AddNewAddressScreen(
              fromCheckout: state.uri.queryParameters['page'] == 'checkout',
              isEnableUpdate: isUpdate,
              address: isUpdate ? addressModel : null,
            ),
          );
        },
      ),
      GoRoute(
        path: favorite,
        builder: (context, state) =>
            _routeHandler(context, child: const WishListScreen()),
        redirect: (context, state) {
          return _redirectUrl(context, state, 3);
        },
      ),
      GoRoute(
        path: wallet,
        builder: (context, state) => _routeHandler(
          context,
          child: WalletScreen(
            token: state.uri.queryParameters['token'] ?? '',
            status: state.uri.queryParameters['flag'] ?? '',
          ),
        ),
        redirect: (context, state) {
          return _redirectUrl(context, state, 9);
        },
      ),
      GoRoute(
        path: referAndEarn,
        builder: (context, state) =>
            _routeHandler(context, child: const ReferAndEarnScreen()),
        redirect: (context, state) {
          return _redirectUrl(context, state, 11);
        },
      ),
      GoRoute(
        path: returnPolicyScreen,
        builder: (context, state) => _routeHandler(
          context,
          child: const HtmlViewerScreen(htmlType: HtmlType.returnPolicy),
        ),
        redirect: (ctx, state) {
          return _redirectUrl(ctx, state, 16);
        },
      ),
      GoRoute(
        path: refundPolicyScreen,
        builder: (context, state) => _routeHandler(
          context,
          child: const HtmlViewerScreen(htmlType: HtmlType.refundPolicy),
        ),
        redirect: (ctx, state) {
          return _redirectUrl(ctx, state, 17);
        },
      ),
      GoRoute(
        path: cancellationPolicyScreen,
        builder: (context, state) => _routeHandler(
          context,
          child: const HtmlViewerScreen(htmlType: HtmlType.cancellationPolicy),
        ),
        redirect: (ctx, state) {
          return _redirectUrl(ctx, state, 18);
        },
      ),
      GoRoute(
        path: orderSearchScreen,
        builder: (context, state) =>
            _routeHandler(context, child: const OrderSearchScreen()),
        redirect: (context, state) {
          return _redirectUrl(context, state, 5);
        },
      ),
      GoRoute(
        path: loyaltyScreen,
        builder: (context, state) =>
            _routeHandler(context, child: const LoyaltyScreen()),
        redirect: (context, state) {
          return _redirectUrl(context, state, 10);
        },
      ),
      GoRoute(
        path: gameScreen,
        builder: (context, state) =>
            _routeHandler(context, child: const GameScreen()),
        redirect: (context, state) {
          return _redirectUrl(context, state, 19);
        },
      ),
      GoRoute(
        path: imagePreview,
        builder: (context, state) {
          return _routeHandler(
            context,
            child: PreviewScreen(
              images: List<String>.from(
                (jsonDecode(state.uri.queryParameters['images'] ?? '[]')
                    as List<dynamic>),
              ),
              selectedIndex:
                  int.tryParse(state.uri.queryParameters['index'] ?? '') ?? 0,
            ),
          );
        },
      ),
      GoRoute(
        path: orderMapInfo,
        builder: (context, state) {
          DeliveryAddress? deliveryAddress =
              state.uri.queryParameters['delivery_address'] == 'null'
              ? null
              : DeliveryAddress.fromJson(
                  jsonDecode(
                    utf8.decode(
                      base64Decode(
                        '${state.uri.queryParameters['delivery_address']?.replaceAll(' ', '+')}',
                      ),
                    ),
                  ),
                );

          return _routeHandler(
            context,
            child: OrderMapInfoWidget(address: deliveryAddress),
          );
        },
      ),
    ],
  );

  static bool isMaintenance(ConfigModel? configModel) {
    if (MaintenanceHelper.isMaintenanceModeEnable(configModel)) {
      if (MaintenanceHelper.checkWebMaintenanceMode(configModel) ||
          MaintenanceHelper.checkCustomerMaintenanceMode(configModel)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static Widget _routeHandler(BuildContext context, {required Widget child}) {
    return isMaintenance(
          Provider.of<SplashProvider>(context, listen: false).configModel,
        )
        ? const MaintenanceScreen()
        : child;
  }

  static String _navigateRoute(
    String path, {
    RouteAction? route = RouteAction.push,
  }) {
    if (route == RouteAction.pushNamedAndRemoveUntil) {
      Get.context?.go(path);
    } else if (route == RouteAction.pushReplacement) {
      Get.context?.pushReplacement(path);
    } else {
      Get.context?.push(path);
    }
    return path;
  }

  static String? _redirectUrl(
    BuildContext ctx,
    GoRouterState state,
    int index,
  ) {
    if (kIsWeb || Navigator.canPop(ctx)) {
      return null;
    } else {
      Provider.of<SplashProvider>(ctx, listen: false).setPageIndex(index);
      return '/';
    }
  }

  static void getBrandProductsRoute({
    required String brandId,
    String? brandName,
  }) {}
}
