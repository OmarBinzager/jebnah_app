import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasource/remote/dio/dio_client.dart';
import '../../utill/app_constants.dart';
import '../models/config_model.dart';
import '../models/currency_model.dart';

class CurrencyProvider extends ChangeNotifier {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;

  CurrencyProvider({
    required this.dioClient,
    required this.sharedPreferences,
  });

  List<CurrencyModel> _currencyList = [];
  CurrencyModel? _selectedCurrency;
  CurrencyModel? _baseCurrency;

  List<CurrencyModel> get currencyList => _currencyList;
  CurrencyModel? get selectedCurrency => _selectedCurrency;
  CurrencyModel? get baseCurrency => _baseCurrency;

  void initCurrency(ConfigModel? config) {
    if (config == null) return;

    if (config.activeCurrencies != null && config.activeCurrencies!.isNotEmpty) {
      _currencyList = config.activeCurrencies!;
    } else {
      _currencyList = [
        CurrencyModel(
          currencyCode: 'YER',
          currencySymbol: config.currencySymbol ?? '﷼',
          symbolPosition: config.currencySymbolPosition ?? 'right',
          decimalDigits: config.decimalPointSettings ?? 2,
          exchangeRate: 1.0,
          isBase: true,
          status: true,
        )
      ];
    }

    _baseCurrency = config.currencyModel ??
        _currencyList.firstWhere(
          (c) => c.isBase == true,
          orElse: () => _currencyList.first,
        );

    String? savedCode = sharedPreferences?.getString(AppConstants.currency);
    if (savedCode != null) {
      _selectedCurrency = _currencyList.firstWhere(
        (c) => c.currencyCode?.toUpperCase() == savedCode.toUpperCase(),
        orElse: () => _baseCurrency ?? _currencyList.first,
      );
    } else {
      _selectedCurrency = _baseCurrency ?? _currencyList.first;
    }

    _updateDioHeader();
    notifyListeners();
  }

  void setCurrency(CurrencyModel currency) {
    _selectedCurrency = currency;
    sharedPreferences?.setString(AppConstants.currency, currency.currencyCode ?? 'YER');
    _updateDioHeader();
    notifyListeners();
  }

  void _updateDioHeader() {
    if (dioClient != null && _selectedCurrency?.currencyCode != null) {
      dioClient!.updateHeader(currencyCode: _selectedCurrency!.currencyCode);
    }
  }

  /// Converts an amount from Base Currency into the user's Selected Currency
  /// Regional Quotation: Rate = how many Base Units equal 1 Foreign Unit (e.g. 1 SAR = 140 YER)
  /// Converted = Amount in Base / Exchange Rate
  double convertPrice(double? price) {
    if (price == null) return 0;
    double rate = _selectedCurrency?.exchangeRate ?? 1.0;
    if (rate <= 0) rate = 1.0;
    return price / rate;
  }
}
