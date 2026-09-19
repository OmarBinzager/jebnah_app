import 'package:flutter/material.dart';
import '../../../common/enums/data_source_enum.dart';
import '../../../data/datasource/local/cache_response.dart';

import '../domain/models/brand_details_model.dart';
import '../../../common/models/api_response_model.dart';
import '../../../common/models/product_model.dart';
import '../domain/reposotories/brand_repo.dart';
import '../../../helper/api_checker_helper.dart';
import '../../../helper/data_sync_helper.dart';
import '../domain/models/brand_model.dart';

class BrandProvider extends ChangeNotifier {
  final BrandRepo? brandRepo;

  BrandProvider({required this.brandRepo});

  List<BrandModel>? _brandList;
  List<BrandModel>? _featuredBrandList;
  BrandDetailsModel? _brandDetails;
  final List<Product> _brandProducts = [];
  int _currentPage = 1;
  bool _hasMoreProducts = true;
  bool _isLoading = false;
  int _currentCarouselIndex = 0;

  // Getters
  List<BrandModel>? get brandList => _brandList;
  List<BrandModel>? get featuredBrandList => _featuredBrandList;
  BrandDetailsModel? get brandDetails => _brandDetails;
  List<Product> get brandProducts => _brandProducts;
  int get currentPage => _currentPage;
  bool get hasMoreProducts => _hasMoreProducts;
  bool get isLoading => _isLoading;
  int get currentCarouselIndex => _currentCarouselIndex;
  int _brandIndex = 0;
  int _selectedProductIndex = -1;

  // Getters
  int get brandIndex => _brandIndex;
  int get selectedProductIndex => _selectedProductIndex;

  void setCurrentCarouselIndex(int index) {
    _currentCarouselIndex = index;
    notifyListeners();
  }

  // دوال التحكم في الاختيار
  void onChangeBrandIndex(int index, {bool notify = true}) {
    _brandIndex = index;
    _selectedProductIndex =
        -1; // إعادة تعيين اختيار المنتج عند تغيير العلامة التجارية
    if (notify) {
      notifyListeners();
    }
  }

  void onChangeSelectIndex(int index) {
    _selectedProductIndex = index;
    notifyListeners();
  } // جلب قائمة العلامات التجارية

  Future<void> getBrandList(BuildContext context, bool reload) async {
    if (brandList == null || reload) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => brandRepo!.getBrandList<CacheResponseData>(
          source: DataSourceEnum.local,
        ),
        fetchFromClient: () =>
            brandRepo!.getBrandList(source: DataSourceEnum.client),
        onResponse: (data, _) {
          _brandList = [];

          // التحقق من نوع البيانات
          if (data is List) {
            // إذا كانت البيانات قائمة مباشرة
            for (var brand in data) {
              if (brand is Map<String, dynamic>) {
                BrandModel brandModel = BrandModel.fromJson(brand);
                _brandList!.add(brandModel);
              }
            }
          } else if (data is Map) {
            // إذا كانت البيانات Map وتحتوي على مفتاح 'data'
            dynamic brandsData = data['data'] ?? data['brands'] ?? data;
            if (brandsData is List) {
              for (var brand in brandsData) {
                if (brand is Map<String, dynamic>) {
                  BrandModel brandModel = BrandModel.fromJson(brand);
                  _brandList!.add(brandModel);
                }
              }
            }
          }

          notifyListeners();
        },
      );
    }
  }

  // جلب العلامات التجارية المميزة
  Future<void> getFeaturedBrands(BuildContext context, bool reload) async {
    if (featuredBrandList == null || reload) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => brandRepo!.getFeaturedBrands<CacheResponseData>(
          source: DataSourceEnum.local,
        ),
        fetchFromClient: () =>
            brandRepo!.getFeaturedBrands(source: DataSourceEnum.client),
        onResponse: (data, _) {
          _featuredBrandList = [];

          print('Data type: ${data.runtimeType}');
          print('Data: $data');

          // التحقق من نوع البيانات - البيانات المرسلة هي List مباشرة
          if (data is List) {
            // إذا كانت البيانات قائمة مباشرة (مثل البيانات التي ترسلها)
            for (var brand in data) {
              if (brand is Map<String, dynamic>) {
                BrandModel brandModel = BrandModel.fromJson(brand);
                _featuredBrandList!.add(brandModel);
              }
            }
          } else if (data is Map) {
            // إذا كانت البيانات Map وتحتوي على مفتاح 'data'
            dynamic brandsData = data['data'] ?? data['brands'] ?? data;
            if (brandsData is List) {
              for (var brand in brandsData) {
                if (brand is Map<String, dynamic>) {
                  BrandModel brandModel = BrandModel.fromJson(brand);
                  _featuredBrandList!.add(brandModel);
                }
              }
            }
          }

          print('Loaded ${_featuredBrandList?.length} featured brands');
          notifyListeners();
        },
      );
    }
  }

  // جلب تفاصيل علامة تجارية محددة
  Future<void> getBrandDetails(
    BuildContext context,
    String brandId,
    bool reload,
  ) async {
    if (brandDetails == null || reload) {
      ApiResponseModel apiResponse = await brandRepo!.getBrandDetails(brandId);
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        _brandDetails = BrandDetailsModel.fromJson(apiResponse.response!.data);
        notifyListeners();
      } else {
        ApiCheckerHelper.checkApi(apiResponse);
      }
    }
  }

  // جلب منتجات علامة تجارية مع pagination
  Future<void> getBrandProducts(
    BuildContext context,
    String brandId, {
    bool reload = false,
  }) async {
    if (reload) {
      _brandProducts.clear();
      _currentPage = 1;
      _hasMoreProducts = true;
    }

    if (!_hasMoreProducts || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    ApiResponseModel apiResponse = await brandRepo!.getBrandProducts(
      brandId,
      page: _currentPage,
    );

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      Map<String, dynamic> responseData = apiResponse.response!.data;
      List<dynamic> productsData = responseData['products'] ?? [];

      for (var product in productsData) {
        if (product is Map<String, dynamic>) {
          _brandProducts.add(Product.fromJson(product));
        }
      }

      // Check if there are more products
      Map<String, dynamic> pagination = responseData['pagination'] ?? {};
      int currentPage = pagination['current_page'] ?? 1;
      int lastPage = pagination['last_page'] ?? 1;
      _hasMoreProducts = currentPage < lastPage;
      _currentPage++;

      notifyListeners();
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
  }

  // إعادة تعيين البيانات
  void clearBrandData() {
    _brandList = null;
    _featuredBrandList = null;
    _brandDetails = null;
    _brandProducts.clear();
    _currentPage = 1;
    _hasMoreProducts = true;
    _isLoading = false;
    notifyListeners();
  }
}
