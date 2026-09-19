import 'package:flutter/material.dart';
import '../../../common/enums/data_source_enum.dart';
import '../../../data/datasource/local/cache_response.dart';
import '../../../features/home/domain/models/seller_model.dart';
import '../../../features/home/domain/models/seller_details_model.dart';
import '../../../common/models/api_response_model.dart';
import '../../../common/models/product_model.dart';
import '../../../features/home/domain/reposotories/seller_repo.dart';
import '../../../helper/api_checker_helper.dart';
import '../../../helper/data_sync_helper.dart';

class SellerProvider extends ChangeNotifier {
  final SellerRepo? sellerRepo;

  SellerProvider({required this.sellerRepo});

  List<SellerModel>? _sellerList;
  List<SellerModel>? _featuredSellerList;
  SellerDetailsModel? _sellerDetails;
  final List<Product> _sellerProducts = [];
  int _currentPage = 1;
  bool _hasMoreProducts = true;
  bool _isLoading = false;

  List<SellerModel>? get sellerList => _sellerList;
  List<SellerModel>? get featuredSellerList => _featuredSellerList;
  SellerDetailsModel? get sellerDetails => _sellerDetails;
  List<Product> get sellerProducts => _sellerProducts;
  int get currentPage => _currentPage;
  bool get hasMoreProducts => _hasMoreProducts;
  bool get isLoading => _isLoading;

  // جلب قائمة البائعين
  Future<void> getSellerList(BuildContext context, bool reload) async {
    if (sellerList == null || reload) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => sellerRepo!.getSellerList<CacheResponseData>(
          source: DataSourceEnum.local,
        ),
        fetchFromClient: () =>
            sellerRepo!.getSellerList(source: DataSourceEnum.client),
        onResponse: (data, _) {
          _sellerList = [];
          data.forEach((seller) {
            SellerModel sellerModel = SellerModel.fromJson(seller);
            _sellerList!.add(sellerModel);
          });
          notifyListeners();
        },
      );
    }
  }

  // جلب البائعين المميزين
  Future<void> getFeaturedSellers(BuildContext context, bool reload) async {
    if (featuredSellerList == null || reload) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => sellerRepo!.getFeaturedSellers<CacheResponseData>(
          source: DataSourceEnum.local,
        ),
        fetchFromClient: () =>
            sellerRepo!.getFeaturedSellers(source: DataSourceEnum.client),
        onResponse: (data, _) {
          _featuredSellerList = [];
          data.forEach((seller) {
            SellerModel sellerModel = SellerModel.fromJson(seller);
            _featuredSellerList!.add(sellerModel);
          });
          notifyListeners();
        },
      );
    }
  }

  // جلب تفاصيل بائع محدد
  Future<void> getSellerDetails(
    BuildContext context,
    String sellerId,
    bool reload,
  ) async {
    if (sellerDetails == null || reload) {
      ApiResponseModel apiResponse = await sellerRepo!.getSellerDetails(
        sellerId,
      );
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        _sellerDetails = SellerDetailsModel.fromJson(
          apiResponse.response!.data,
        );
        notifyListeners();
      } else {
        ApiCheckerHelper.checkApi(apiResponse);
      }
    }
  }

  // جلب منتجات بائع مع pagination
  Future<void> getSellerProducts(
    BuildContext context,
    String sellerId, {
    bool reload = false,
  }) async {
    if (reload) {
      _sellerProducts.clear();
      _currentPage = 1;
      _hasMoreProducts = true;
    }

    if (!_hasMoreProducts || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    ApiResponseModel apiResponse = await sellerRepo!.getSellerProducts(
      sellerId,
      page: _currentPage,
    );

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      Map<String, dynamic> responseData = apiResponse.response!.data;
      List<dynamic> productsData = responseData['products'] ?? [];

      List<Product> newProducts = [];
      productsData.forEach((product) {
        newProducts.add(Product.fromJson(product));
      });

      _sellerProducts.addAll(newProducts);

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
  void clearSellerData() {
    _sellerList = null;
    _featuredSellerList = null;
    _sellerDetails = null;
    _sellerProducts.clear();
    _currentPage = 1;
    _hasMoreProducts = true;
    notifyListeners();
  }
}
