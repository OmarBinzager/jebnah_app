import 'package:flutter/material.dart';
import '../../../common/enums/data_source_enum.dart';
import '../../../data/datasource/local/cache_response.dart';

import '../../../common/models/api_response_model.dart';
import '../../../common/models/product_model.dart';
import '../domain/models/banner_model.dart';
import '../domain/reposotories/banner_repo.dart';
import '../../../helper/api_checker_helper.dart';
import '../../../helper/data_sync_helper.dart';

class BannerProvider extends ChangeNotifier {
  final BannerRepo? bannerRepo;

  BannerProvider({required this.bannerRepo});

  List<BannerModel>? _bannerList;
  final List<Product> _productList = [];
  int _currentIndex = 0;

  List<BannerModel>? get bannerList => _bannerList;
  List<Product> get productList => _productList;
  int get currentIndex => _currentIndex;
  int _currentCarouselIndex = 0;
  int get currentCarouselIndex => _currentCarouselIndex;
  void setCurrentCarouselIndex(int index) {
    _currentCarouselIndex = index;
    notifyListeners();
  }

  Future<void> getBannerList(BuildContext context, bool reload) async {
    if (bannerList == null || reload) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => bannerRepo!.getBannerList<CacheResponseData>(
          source: DataSourceEnum.local,
        ),
        fetchFromClient: () =>
            bannerRepo!.getBannerList(source: DataSourceEnum.client),
        onResponse: (data, _) {
          _bannerList = [];
          data.forEach((category) {
            BannerModel bannerModel = BannerModel.fromJson(category);
            if (bannerModel.productId != null) {
              getProductDetails(context, bannerModel.productId.toString());
            }
            _bannerList!.add(bannerModel);
          });
          notifyListeners();
        },
      );
    }
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void getProductDetails(BuildContext context, String productID) async {
    ApiResponseModel apiResponse = await bannerRepo!.getProductDetails(
      productID,
    );
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _productList.add(Product.fromJson(apiResponse.response!.data));
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
  }
}
