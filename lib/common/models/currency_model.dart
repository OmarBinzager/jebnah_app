class CurrencyModel {
  int? id;
  String? country;
  String? currencyCode;
  String? currencySymbol;
  String? symbolPosition;
  int? decimalDigits;
  double? exchangeRate;
  bool? isBase;
  bool? status;

  CurrencyModel({
    this.id,
    this.country,
    this.currencyCode,
    this.currencySymbol,
    this.symbolPosition = 'right',
    this.decimalDigits = 2,
    this.exchangeRate = 1.0,
    this.isBase = false,
    this.status = true,
  });

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    country = json['country'];
    currencyCode = json['currency_code'];
    currencySymbol = json['currency_symbol'];
    symbolPosition = json['symbol_position'] ?? 'right';
    decimalDigits = json['decimal_digits'] != null ? int.tryParse(json['decimal_digits'].toString()) ?? 2 : 2;
    exchangeRate = json['exchange_rate'] != null ? double.tryParse(json['exchange_rate'].toString()) ?? 1.0 : 1.0;
    isBase = json['is_base'] == true || json['is_base'] == 1 || json['is_base'] == '1';
    status = json['status'] == true || json['status'] == 1 || json['status'] == '1';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['country'] = country;
    data['currency_code'] = currencyCode;
    data['currency_symbol'] = currencySymbol;
    data['symbol_position'] = symbolPosition;
    data['decimal_digits'] = decimalDigits;
    data['exchange_rate'] = exchangeRate;
    data['is_base'] = isBase;
    data['status'] = status;
    return data;
  }
}
