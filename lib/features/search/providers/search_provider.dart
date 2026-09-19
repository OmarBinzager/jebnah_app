import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../common/models/api_response_model.dart';
import '../../../common/models/product_model.dart';
import '../../../helper/api_checker_helper.dart';
import '../domain/reposotories/search_repo.dart';

class SearchProvider with ChangeNotifier {
  final SearchRepo? searchRepo;

  SearchProvider({required this.searchRepo});

  String? _selectedFilter;
  double? _lowerValue;
  double? _upperValue;
  List<String?> _historyList = [];

  String? get selectedFilter => _selectedFilter;
  double? get lowerValue => _lowerValue;
  double? get upperValue => _upperValue;

  bool _isClear = true;
  String _searchText = '';
  bool _isSearch = true;

  bool get isClear => _isClear;
  bool get isSearch => _isSearch;

  String get searchText => _searchText;
  List<String?> get historyList => _historyList;

  final List<Product> _categoryProductList = [];
  List<Product> get categoryProductList => _categoryProductList;

  List<String?> _allSortBy = [];
  List<String?> get allSortBy => _allSortBy;

  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;
  int _searchLength = 0;
  int get searchLength => _searchLength;

  // ========== الفلاتر ==========
  List<String> _selectedColors = [];
  List<String> _selectedModels = [];
  List<String> _selectedCountries = [];
  List<String> _selectedCapacities = [];
  List<String> _selectedBrands = [];
  List<String> _selectedCategories = [];
  List<String> _selectedSellers = []; // إضافة البائعين

  List<String> get selectedColors => _selectedColors;
  List<String> get selectedModels => _selectedModels;
  List<String> get selectedCountries => _selectedCountries;
  List<String> get selectedCapacities => _selectedCapacities;
  List<String> get selectedBrands => _selectedBrands;
  List<String> get selectedCategories => _selectedCategories;
  List<String> get selectedSellers => _selectedSellers; // إضافة

  // الفلاتر المتاحة من الـ API
  Map<String, dynamic> _availableFilters = {};
  Map<String, dynamic> get availableFilters => _availableFilters;

  // عدد الفلاتر النشطة
  int get activeFiltersCount {
    int count = 0;
    if (_selectedColors.isNotEmpty) count++;
    if (_selectedModels.isNotEmpty) count++;
    if (_selectedCountries.isNotEmpty) count++;
    if (_selectedCapacities.isNotEmpty) count++;
    if (_selectedBrands.isNotEmpty) count++;
    if (_selectedCategories.isNotEmpty) count++;
    if (_selectedSellers.isNotEmpty) count++; // إضافة
    if (_lowerValue != null && _lowerValue! > 0) count++;
    if (_upperValue != null && _upperValue! > 0) count++;
    if (_selectedFilter != null && _selectedFilter!.isNotEmpty) count++;
    return count;
  }

  void onChangeSearchStatus() {
    _isSearch = !_isSearch;
    notifyListeners();
  }

  void setSearchValue(String searchText) {
    _searchController = TextEditingController(text: searchText);
    _searchLength = searchText.length;
    notifyListeners();
  }

  void setFilterValue(String? value, {bool isUpdate = true}) {
    _selectedFilter = value;
    if (isUpdate) {
      notifyListeners();
    }
  }

  void initializeAllSortBy({bool notify = true}) {
    if (_allSortBy.isEmpty) {
      _allSortBy = [];
      _allSortBy = searchRepo!.getAllSortByList();
    }
    _selectedFilter = null;
    if (notify) {
      notifyListeners();
    }
  }

  void setLowerAndUpperValue(
    double? lower,
    double? upper, {
    bool isUpdate = true,
  }) {
    _lowerValue = lower;
    _upperValue = upper;
    if (isUpdate) {
      notifyListeners();
    }
  }

  void setSearchText(String text) {
    _searchText = text;
    notifyListeners();
  }

  void cleanSearchProduct() {
    _isClear = true;
    _searchText = '';
    notifyListeners();
  }

  // ========== دوال التحكم في الفلاتر ==========

  void toggleColor(String color) {
    if (_selectedColors.contains(color)) {
      _selectedColors.remove(color);
    } else {
      _selectedColors.add(color);
    }
    notifyListeners();
  }

  void toggleModel(String model) {
    if (_selectedModels.contains(model)) {
      _selectedModels.remove(model);
    } else {
      _selectedModels.add(model);
    }
    notifyListeners();
  }

  void toggleCountry(String country) {
    if (_selectedCountries.contains(country)) {
      _selectedCountries.remove(country);
    } else {
      _selectedCountries.add(country);
    }
    notifyListeners();
  }

  void toggleCapacity(String capacity) {
    if (_selectedCapacities.contains(capacity)) {
      _selectedCapacities.remove(capacity);
    } else {
      _selectedCapacities.add(capacity);
    }
    notifyListeners();
  }

  void toggleBrand(String brandId) {
    if (_selectedBrands.contains(brandId)) {
      _selectedBrands.remove(brandId);
    } else {
      _selectedBrands.add(brandId);
    }
    notifyListeners();
  }

  void toggleCategory(String categoryId) {
    if (_selectedCategories.contains(categoryId)) {
      _selectedCategories.remove(categoryId);
    } else {
      _selectedCategories.add(categoryId);
    }
    notifyListeners();
  }

  // إضافة دالة للبائعين
  void toggleSeller(String sellerId) {
    if (_selectedSellers.contains(sellerId)) {
      _selectedSellers.remove(sellerId);
    } else {
      _selectedSellers.add(sellerId);
    }
    notifyListeners();
  }

  void resetAllFilters() {
    _selectedColors = [];
    _selectedModels = [];
    _selectedCountries = [];
    _selectedCapacities = [];
    _selectedBrands = [];
    _selectedCategories = [];
    _selectedSellers = []; // إضافة
    _lowerValue = null;
    _upperValue = null;
    _selectedFilter = null;
    notifyListeners();
  }

  void setFilters({
    List<String>? colors,
    List<String>? models,
    List<String>? countries,
    List<String>? capacities,
    List<String>? brands,
    List<String>? categories,
    List<String>? sellers, // إضافة
    double? priceLow,
    double? priceHigh,
    String? sortBy,
  }) {
    if (colors != null) _selectedColors = colors;
    if (models != null) _selectedModels = models;
    if (countries != null) _selectedCountries = countries;
    if (capacities != null) _selectedCapacities = capacities;
    if (brands != null) _selectedBrands = brands;
    if (categories != null) _selectedCategories = categories;
    if (sellers != null) _selectedSellers = sellers; // إضافة
    if (priceLow != null) _lowerValue = priceLow;
    if (priceHigh != null) _upperValue = priceHigh;
    if (sortBy != null) _selectedFilter = sortBy;
    notifyListeners();
  }

  ProductModel? _searchProductModel;
  ProductModel? get searchProductModel => _searchProductModel;

  Future<void> getSearchProduct({
    required int offset,
    required String query,
    double? priceLow,
    double? priceHigh,
    String? filterType,
    bool isUpdate = false,
    List<String>? colors,
    List<String>? models,
    List<String>? countries,
    List<String>? capacities,
    List<String>? brands,
    List<String>? categories,
    List<String>? sellers, // إضافة
  }) async {
    if (offset == 1) {
      _searchProductModel?.products = null;
      if (isUpdate) {
        notifyListeners();
      }
    }

    // استخدام الفلاتر المخزنة إذا لم يتم تمريرها
    colors = colors ?? _selectedColors;
    models = models ?? _selectedModels;
    countries = countries ?? _selectedCountries;
    capacities = capacities ?? _selectedCapacities;
    brands = brands ?? _selectedBrands;
    categories = categories ?? _selectedCategories;
    sellers = sellers ?? _selectedSellers; // إضافة

    priceLow = priceLow ?? _lowerValue;
    priceHigh = priceHigh ?? _upperValue;
    filterType = filterType ?? _selectedFilter;

    ApiResponseModel apiResponse = await searchRepo!.getSearchProductList(
      offset: offset,
      query: query,
      priceHigh: priceHigh,
      priceLow: priceLow,
      sortBy: filterType,
      colors: colors?.isNotEmpty == true ? colors : null,
      models: models?.isNotEmpty == true ? models : null,
      countries: countries?.isNotEmpty == true ? countries : null,
      capacities: capacities?.isNotEmpty == true ? capacities : null,
      brands: brands?.isNotEmpty == true ? brands : null,
      categories: categories?.isNotEmpty == true ? categories : null,
      sellers: sellers?.isNotEmpty == true ? sellers : null, // إضافة
    );

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      Map<String, dynamic> responseData = apiResponse.response?.data;

      if (offset == 1) {
        _searchProductModel = ProductModel.fromJson(responseData);
      } else {
        _searchProductModel?.totalSize = ProductModel.fromJson(
          responseData,
        ).totalSize;
        _searchProductModel?.offset = ProductModel.fromJson(
          responseData,
        ).offset;
        _searchProductModel?.products?.addAll(
          ProductModel.fromJson(responseData).products ?? [],
        );
      }

      // استخراج الفلاتر المتاحة
      if (responseData['available_filters'] != null) {
        _availableFilters = Map<String, dynamic>.from(
          responseData['available_filters'],
        );
      }
    } else {
      _searchProductModel = ProductModel(products: []);
      ApiCheckerHelper.checkApi(apiResponse);
    }

    notifyListeners();
  }

  Future<void> searchWithCurrentFilters({
    required int offset,
    required String query,
    bool isUpdate = false,
  }) async {
    await getSearchProduct(
      offset: offset,
      query: query,
      priceLow: _lowerValue,
      priceHigh: _upperValue,
      filterType: _selectedFilter,
      colors: _selectedColors,
      models: _selectedModels,
      countries: _selectedCountries,
      capacities: _selectedCapacities,
      brands: _selectedBrands,
      categories: _selectedCategories,
      sellers: _selectedSellers, // إضافة
      isUpdate: isUpdate,
    );
  }

  void initHistoryList() {
    _historyList = [];
    _historyList.addAll(searchRepo!.getSearchAddress());
  }

  void saveSearchAddress(String? searchAddress, {bool isUpdate = true}) async {
    if (searchAddress != null && !_historyList.contains(searchAddress)) {
      _historyList.add(searchAddress);
      searchRepo!.saveSearchAddress(searchAddress);
      if (isUpdate) {
        notifyListeners();
      }
    }
  }

  void clearSearchAddress() async {
    searchRepo!.clearSearchAddress();
    _historyList = [];
    notifyListeners();
  }
}
