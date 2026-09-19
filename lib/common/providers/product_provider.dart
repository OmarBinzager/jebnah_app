import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../common/enums/data_source_enum.dart';
import '../../../../common/enums/product_filter_type_enum.dart';
import '../../../../common/models/api_response_model.dart';
import '../../../../common/models/review_model.dart';
import '../../../../common/providers/cart_provider.dart';
import '../../../../common/models/product_model.dart';
import '../../../../common/reposotories/product_repo.dart';
import '../../../../features/search/domain/reposotories/search_repo.dart';
import '../../../../helper/api_checker_helper.dart';
import '../../../../helper/data_sync_helper.dart';
import '../../../../main.dart';
import '../../../../utill/product_type.dart';
import 'package:provider/provider.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepo productRepo;
  final SearchRepo searchRepo;

  ProductProvider({required this.productRepo, required this.searchRepo});

  ProductModel? _allProductModel;
  Product? _product;
  int? _imageSliderIndex;
  ProductModel? _dailyProductModel;
  ProductModel? _featuredProductModel;
  ProductModel? _mostViewedProductModel;
  ProductFilterType _selectedFilterType = ProductFilterType.latest;

  Product? get product => _product;
  ProductModel? get allProductModel => _allProductModel;
  ProductModel? get dailyProductModel => _dailyProductModel;
  ProductModel? get featuredProductModel => _featuredProductModel;
  ProductModel? get mostViewedProductModel => _mostViewedProductModel;
  int? get imageSliderIndex => _imageSliderIndex;
  ProductFilterType get selectedFilterType => _selectedFilterType;

  // أضف هذه المتغيرات في بداية الكلاس
  ProductModel? _relatedProductsModel;
  ProductModel? get relatedProductsModel => _relatedProductsModel;

  Future<void> getAllProductList(
    int offset,
    bool reload, {
    bool isUpdate = true,
  }) async {
    if (reload || offset == 1) {
      _allProductModel = null;

      if (isUpdate) {
        notifyListeners();
      }
    }

    if (offset == 1) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => productRepo.getAllProductList(
          offset,
          _selectedFilterType,
          source: DataSourceEnum.local,
        ),
        fetchFromClient: () => productRepo.getAllProductList(
          offset,
          _selectedFilterType,
          source: DataSourceEnum.client,
        ),
        onResponse: (data, _) {
          _allProductModel = ProductModel.fromJson(data);

          notifyListeners();
        },
      );
    } else {
      ApiResponseModel? response = await productRepo
          .getAllProductList<Response>(
            offset,
            _selectedFilterType,
            source: DataSourceEnum.client,
          );

      if (response.response?.data != null &&
          response.response?.statusCode == 200) {
        final ProductModel tempProductModel = ProductModel.fromJson(
          response.response?.data,
        );

        _allProductModel!.totalSize = tempProductModel.totalSize;
        _allProductModel!.offset = tempProductModel.offset;
        _allProductModel!.products!.addAll(tempProductModel.products!);

        notifyListeners();
      } else {
        ApiCheckerHelper.checkApi(response);
      }
    }
  }

  Future<void> getItemList(
    int offset, {
    bool isUpdate = true,
    bool isReload = true,
    required String? productType,
  }) async {
    if (offset == 1) {
      if (productType == ProductType.dailyItem) {
        _dailyProductModel = null;
      } else if (productType == ProductType.featuredItem) {
        _featuredProductModel = null;
      } else if (productType == ProductType.mostReviewed) {
        _mostViewedProductModel = null;
      }

      if (isUpdate) {
        notifyListeners();
      }
    }

    if (offset == 1) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => productRepo.getItemList(
          offset,
          productType,
          source: DataSourceEnum.local,
        ),
        fetchFromClient: () => productRepo.getItemList(
          offset,
          productType,
          source: DataSourceEnum.client,
        ),
        onResponse: (data, _) {
          if (productType == ProductType.dailyItem) {
            _dailyProductModel = ProductModel.fromJson(data);
          } else if (productType == ProductType.featuredItem) {
            _featuredProductModel = ProductModel.fromJson(data);
          } else if (productType == ProductType.mostReviewed) {
            _mostViewedProductModel = ProductModel.fromJson(data);
          }

          notifyListeners();
        },
      );
    } else {
      ApiResponseModel apiResponse = await productRepo.getItemList(
        offset,
        productType,
        source: DataSourceEnum.client,
      );

      if (apiResponse.response?.statusCode == 200) {
        if (offset == 1) {
          if (productType == ProductType.dailyItem) {
            _dailyProductModel = ProductModel.fromJson(
              apiResponse.response?.data,
            );
          } else if (productType == ProductType.featuredItem) {
            _featuredProductModel = ProductModel.fromJson(
              apiResponse.response?.data,
            );
          } else if (productType == ProductType.mostReviewed) {
            _mostViewedProductModel = ProductModel.fromJson(
              apiResponse.response?.data,
            );
          }
        } else {
          if (productType == ProductType.dailyItem) {
            _dailyProductModel?.offset = ProductModel.fromJson(
              apiResponse.response?.data,
            ).offset;
            _dailyProductModel?.totalSize = ProductModel.fromJson(
              apiResponse.response?.data,
            ).totalSize;
            _dailyProductModel?.products?.addAll(
              ProductModel.fromJson(apiResponse.response?.data).products ?? [],
            );
          } else if (productType == ProductType.featuredItem) {
            _featuredProductModel?.offset = ProductModel.fromJson(
              apiResponse.response?.data,
            ).offset;
            _featuredProductModel?.totalSize = ProductModel.fromJson(
              apiResponse.response?.data,
            ).totalSize;
            _featuredProductModel?.products?.addAll(
              ProductModel.fromJson(apiResponse.response?.data).products ?? [],
            );
          } else if (productType == ProductType.mostReviewed) {
            _mostViewedProductModel?.offset = ProductModel.fromJson(
              apiResponse.response?.data,
            ).offset;
            _mostViewedProductModel?.totalSize = ProductModel.fromJson(
              apiResponse.response?.data,
            ).totalSize;
            _mostViewedProductModel?.products?.addAll(
              ProductModel.fromJson(apiResponse.response?.data).products ?? [],
            );
          }
        }
      } else {
        ApiCheckerHelper.checkApi(apiResponse);
      }
      notifyListeners();
    }
  }

  Future<Product?> getProductDetails(
    String productID, {
    bool searchQuery = false,
  }) async {
    final CartProvider cartProvider = Provider.of<CartProvider>(
      Get.context!,
      listen: false,
    );

    _product = null;
    ApiResponseModel apiResponse = await productRepo.getProductDetails(
      productID,
      searchQuery,
    );

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _product = Product.fromJson(apiResponse.response!.data);
      cartProvider.initData(_product!);
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();

    return _product;
  }

  Reviews? _productReviews;
  Reviews? get productReviews => _productReviews;

  Future<void> getProductReviews({
    String? id,
    int? offset,
    bool reload = false,
    bool isUpdate = true,
  }) async {
    if (reload || offset == 1) {
      _productReviews?.reviewList = null;

      if (isUpdate) {
        notifyListeners();
      }
    }
    ApiResponseModel apiResponse = await productRepo.getProductReviews(
      productId: id,
      offset: offset,
    );
    if (apiResponse.response!.statusCode == 200) {
      final Reviews tempReviews = Reviews.fromJson(
        apiResponse.response!.data["reviews"],
      );
      if (offset == 1) {
        _productReviews = tempReviews;
      } else {
        _productReviews?.totalSize = tempReviews.totalSize;
        _productReviews?.offset = tempReviews.offset;
        _productReviews?.reviewList?.addAll(tempReviews.reviewList ?? []);
      }
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void setImageSliderSelectedIndex(int selectedIndex) {
    _imageSliderIndex = selectedIndex;
    notifyListeners();
  }

  void onChangeProductFilterType(ProductFilterType type) {
    _selectedFilterType = type;
    notifyListeners();
  }

  Future<void> getRelatedProducts(
    String productId, {
    int offset = 1,
    bool reload = false,
    bool isUpdate = true,
  }) async {
    if (reload || offset == 1) {
      _relatedProductsModel = null;
      if (isUpdate) {
        notifyListeners();
      }
    }

    try {
      final apiResponse = await productRepo.getRelatedProducts(
        productId,
        offset: offset,
        source: DataSourceEnum.client,
      );

      if (apiResponse.response?.statusCode == 200) {
        dynamic data = apiResponse.response?.data;

        ProductModel tempProductModel;

        // التحقق من نوع البيانات
        if (data is List) {
          // إذا كانت البيانات قائمة مباشرة
          tempProductModel = ProductModel(
            products: data.map((item) => Product.fromJson(item)).toList(),
            totalSize: data.length,
            offset: offset,
          );
        } else if (data is Map<String, dynamic>) {
          // إذا كانت البيانات بالشكل المتوقع
          tempProductModel = ProductModel.fromJson(data);
        } else {
          tempProductModel = ProductModel(
            products: [],
            totalSize: 0,
            offset: 0,
          );
        }

        if (offset == 1) {
          _relatedProductsModel = tempProductModel;
        } else {
          _relatedProductsModel?.offset = tempProductModel.offset;
          _relatedProductsModel?.totalSize = tempProductModel.totalSize;
          _relatedProductsModel?.products?.addAll(
            tempProductModel.products ?? [],
          );
        }
        notifyListeners();
      } else {
        ApiCheckerHelper.checkApi(apiResponse);
      }
    } catch (e) {
      print('Error loading related products: $e');
      _relatedProductsModel = ProductModel(
        products: [],
        totalSize: 0,
        offset: 0,
      );
      notifyListeners();
    }
  }

  // أضف هذا المتغير في بداية كلاس ProductProvider
  List<Product>? _relatedProductsList;
  List<Product>? get relatedProductsList => _relatedProductsList;

  // أضف هذه الدالة في كلاس ProductProvider
  Future<void> getRelatedProductsSimple(String productId) async {
    try {
      final apiResponse = await productRepo.getRelatedProducts(
        productId,
        offset: 1,
        source: DataSourceEnum.client,
      );

      if (apiResponse.response?.statusCode == 200) {
        final dynamic data = apiResponse.response?.data;

        List<Product> products = [];

        if (data is List) {
          // إذا كانت البيانات قائمة مباشرة
          products = data.map((item) => Product.fromJson(item)).toList();
        } else if (data is Map<String, dynamic> &&
            data.containsKey('products')) {
          // إذا كانت البيانات بالشكل المتوقع مع مفتاح products
          products = (data['products'] as List)
              .map((item) => Product.fromJson(item))
              .toList();
        }

        _relatedProductsList = products;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading related products: $e');
      _relatedProductsList = [];
      notifyListeners();
    }
  }
}
