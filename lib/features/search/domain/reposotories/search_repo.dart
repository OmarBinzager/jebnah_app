import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/models/api_response_model.dart';
import '../../../../data/datasource/remote/dio/dio_client.dart';
import '../../../../data/datasource/remote/exception/api_error_handler.dart';
import '../../../../utill/app_constants.dart';

class SearchRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;

  SearchRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponseModel> getSearchProductList({
    required int offset,
    String? query,
    String? sortBy,
    double? priceLow,
    double? priceHigh,
    List<String>? colors,
    List<String>? models,
    List<String>? countries,
    List<String>? capacities,
    List<String>? brands,
    List<String>? categories,
    List<String>? sellers, // إضافة البائعين
  }) async {
    String url = '${AppConstants.searchUri}?limit=10&offset=$offset';

    // البحث بالنص
    if (query != null && query.isNotEmpty) {
      url = '$url&name=${Uri.encodeComponent(query)}';
    }

    // فلترة السعر
    if (priceLow != null && priceLow > 0) {
      url = '$url&price_low=$priceLow';
    }
    if (priceHigh != null && priceHigh > 0) {
      url = '$url&price_high=$priceHigh';
    }

    // الترتيب
    if (sortBy != null && sortBy.isNotEmpty) {
      url = '$url&sort_by=$sortBy';
    }

    // الألوان (نصوص)
    if (colors != null && colors.isNotEmpty) {
      for (String color in colors) {
        url = '$url&colors[]=${Uri.encodeComponent(color)}';
      }
    }

    // الموديلات (نصوص)
    if (models != null && models.isNotEmpty) {
      for (String model in models) {
        url = '$url&models[]=${Uri.encodeComponent(model)}';
      }
    }

    // بلدان الصنع (نصوص)
    if (countries != null && countries.isNotEmpty) {
      for (String country in countries) {
        url = '$url&countries[]=${Uri.encodeComponent(country)}';
      }
    }

    // السعات (نصوص)
    if (capacities != null && capacities.isNotEmpty) {
      for (String capacity in capacities) {
        url = '$url&capacities[]=${Uri.encodeComponent(capacity)}';
      }
    }

    // البراندات (أرقام) - نرسلها كـ string مفصول بفواصل
    if (brands != null && brands.isNotEmpty) {
      String brandsString = brands.join(',');
      url = '$url&brands=$brandsString';
    }

    // الفئات (أرقام) - نرسلها كـ string مفصول بفواصل
    if (categories != null && categories.isNotEmpty) {
      String categoriesString = categories.join(',');
      url = '$url&categories=$categoriesString';
    }

    // البائعين (أرقام) - نرسلها كـ string مفصول بفواصل
    if (sellers != null && sellers.isNotEmpty) {
      String sellersString = sellers.join(',');
      url = '$url&sellers=$sellersString';
    }

    try {
      final response = await dioClient!.get(url);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // الحصول على قائمة خيارات الترتيب
  List<String> getAllSortByList() {
    List<String> sortByList = [
      'low_to_high',
      'high_to_low',
      'ascending',
      'descending',
    ];
    return sortByList;
  }

  // حفظ البحث
  Future<void> saveSearchAddress(String? searchAddress) async {
    try {
      List<String> searchKeywordList =
          sharedPreferences!.getStringList(AppConstants.searchAddress) ?? [];
      if (searchAddress != null &&
          searchAddress.isNotEmpty &&
          !searchKeywordList.contains(searchAddress)) {
        searchKeywordList.add(searchAddress);
      }
      await sharedPreferences!.setStringList(
        AppConstants.searchAddress,
        searchKeywordList,
      );
    } catch (e) {
      rethrow;
    }
  }

  List<String> getSearchAddress() {
    return sharedPreferences!.getStringList(AppConstants.searchAddress) ?? [];
  }

  Future<bool> clearSearchAddress() async {
    return sharedPreferences!.setStringList(AppConstants.searchAddress, []);
  }
}
