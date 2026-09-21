import '../../../../common/enums/data_source_enum.dart';
import '../../../../common/reposotories/data_sync_repo.dart';
import '../../../../data/datasource/remote/exception/api_error_handler.dart';
import '../../../../common/models/api_response_model.dart';
import '../../../../utill/app_constants.dart';

class SplashRepo extends DataSyncRepo {
  @override
  SplashRepo({required super.sharedPreferences, required super.dioClient});

  Future<ApiResponseModel<T>> getConfig<T>({
    required DataSourceEnum source,
  }) async {
    return await fetchData<T>(AppConstants.configUri, source);
  }

  Future<bool> initSharedData() async {
    if (!sharedPreferences!.containsKey(AppConstants.theme)) {
      await sharedPreferences!.setBool(AppConstants.theme, false);
    }
    if (!sharedPreferences!.containsKey(AppConstants.countryCode)) {
      await sharedPreferences!.setString(
        AppConstants.countryCode,
        AppConstants.languages[0].countryCode!,
      );
    }
    if (!sharedPreferences!.containsKey(AppConstants.languageCode)) {
      await sharedPreferences!.setString(
        AppConstants.languageCode,
        AppConstants.languages[0].languageCode!,
      );
    }
    if (!sharedPreferences!.containsKey(AppConstants.cartList)) {
      await sharedPreferences!.setStringList(AppConstants.cartList, []);
    }
    if (!sharedPreferences!.containsKey(AppConstants.onBoardingSkip)) {
      await sharedPreferences!.setBool(AppConstants.onBoardingSkip, true);
    }

    return true;
  }

  Future<bool> removeSharedData() async {
    String? lang = sharedPreferences!.getString(AppConstants.languageCode);
    String? country = sharedPreferences!.getString(AppConstants.countryCode);
    bool? theme = sharedPreferences!.getBool(AppConstants.theme);
    bool? onBoarding = sharedPreferences!.getBool(AppConstants.onBoardingSkip);

    await sharedPreferences!.clear();

    if (lang != null) {
      await sharedPreferences!.setString(AppConstants.languageCode, lang);
    }
    if (country != null) {
      await sharedPreferences!.setString(AppConstants.countryCode, country);
    }
    if (theme != null) {
      await sharedPreferences!.setBool(AppConstants.theme, theme);
    }
    if (onBoarding != null) {
      await sharedPreferences!.setBool(AppConstants.onBoardingSkip, onBoarding);
    }

    return true;
  }

  void disableIntro() {
    sharedPreferences!.setBool(AppConstants.onBoardingSkip, true);
  }

  bool showIntro() {
    return false;
  }

  Future<ApiResponseModel> getOfflinePaymentMethod() async {
    try {
      final response = await dioClient.get(AppConstants.offlinePaymentMethod);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel<T>> getDeliveryInfo<T>({
    required DataSourceEnum source,
  }) async {
    return await fetchData<T>(AppConstants.getDeliveryInfo, source);
  }
}
