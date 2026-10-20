import 'package:flutter/material.dart';
import '../common/models/config_model.dart';
import '../common/models/product_model.dart';
import '../common/providers/currency_provider.dart';
import '../features/splash/providers/splash_provider.dart';
import 'package:provider/provider.dart';

class PriceConverterHelper {
  static String convertPrice(
    BuildContext context,
    double? price, {
    double? discount,
    String? discountType,
  }) {
    if (price == null) return '';

    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = price - discount;
      } else if (discountType == 'percent') {
        price = price - ((discount / 100) * price);
      }
    }

    CurrencyProvider? currencyProvider;
    try {
      currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
    } catch (_) {}

    final selectedCurrency = currencyProvider?.selectedCurrency;
    double exchangeRate = selectedCurrency?.exchangeRate ?? 1.0;
    if (exchangeRate <= 0) exchangeRate = 1.0;

    // Direct regional quotation: Foreign Price = Base Price / Rate
    double convertedPrice = price / exchangeRate;

    ConfigModel? config = Provider.of<SplashProvider>(context, listen: false).configModel;

    String symbol = selectedCurrency?.currencySymbol ?? config?.currencySymbol ?? '﷼';
    bool isLeft = (selectedCurrency?.symbolPosition ?? config?.currencySymbolPosition ?? 'right') == 'left';
    int decimalDigits = selectedCurrency?.decimalDigits ?? config?.decimalPointSettings ?? 2;

    String formattedNumber = convertedPrice
        .toStringAsFixed(decimalDigits)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return !isLeft ? '$formattedNumber $symbol' : '$symbol $formattedNumber';
  }

  static double? convertWithDiscount(
    double? price,
    double? discount,
    String? discountType, {
    double? maxDiscount,
  }) {
    if (discountType == 'amount') {
      price = price! - discount!;
    } else if (discountType == 'percent') {
      if (maxDiscount != null && ((discount! / 100) * price!) > maxDiscount) {
        price = price - maxDiscount;
      } else {
        price = price! - ((discount! / 100) * price);
      }
    }
    return price;
  }
  // static double vatTaxCalculate(double price, Product product) {
  //   double _price;
  //   if(Provider.of<SplashProvider>(Get.context, listen: false).configModel.isVatTexInclude) {
  //    _price = convertWithDiscount(price, product.tax, product.taxType);
  //   }else{
  //     _price = price;
  //   }
  //   return _price;
  //
  // }

  static double calculation(
    double amount,
    double discount,
    String type,
    int quantity,
  ) {
    double calculatedAmount = 0;
    if (type == 'amount') {
      calculatedAmount = discount * quantity;
    } else if (type == 'percent') {
      calculatedAmount = (discount / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(
    BuildContext context,
    double? discount,
    String? discountType,
  ) {
    CurrencyProvider? currencyProvider;
    try {
      currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
    } catch (_) {}
    final symbol = currencyProvider?.selectedCurrency?.currencySymbol ??
        Provider.of<SplashProvider>(context, listen: false).configModel?.currencySymbol ?? '﷼';
    return '$discount${discountType == 'percent' ? '%' : ' $symbol'} OFF';
  }

  /// Converts a base currency numeric amount to selected currency numeric amount
  static double convertAmount(BuildContext context, double? amount) {
    if (amount == null) return 0;
    CurrencyProvider? currencyProvider;
    try {
      currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
    } catch (_) {}
    return currencyProvider?.convertPrice(amount) ?? amount;
  }

  static ({double? discount, DiscountType type}) convertProductDiscount({
    required double? price,
    required double? discount,
    required String? discountType,
    required CategoryDiscount? categoryDiscount,
  }) {
    double? categoryDiscountPrice;

    if (categoryDiscount != null) {
      categoryDiscountPrice = convertWithDiscount(
        price,
        categoryDiscount.discountAmount,
        categoryDiscount.discountType,
        maxDiscount: categoryDiscount.maximumAmount,
      );
    }

    final productDiscount = convertWithDiscount(price, discount, discountType);

    if (categoryDiscountPrice != null &&
        !categoryDiscountPrice.isNegative &&
        categoryDiscountPrice < price! &&
        (categoryDiscountPrice < (productDiscount ?? 0))) {
      return (
        discount: categoryDiscountPrice,
        type: DiscountType.categoryDiscount,
      );
    } else {
      return (discount: productDiscount, type: DiscountType.productDiscount);
    }
  }

  // static double? convertProductDiscount(double? price, {double? categoryDiscount, String? categoryDiscountType, double? maxDiscount, double? productDiscount, String? productDiscountType}) {
  //   // Calculate category discount using existing convertWithDiscount method
  //   double? categoryDiscountedPrice = convertWithDiscount(
  //     price,
  //     categoryDiscount,
  //     categoryDiscountType,
  //     maxDiscount: maxDiscount,
  //   );
  //
  //   // Calculate product discount using existing convertWithDiscount method
  //   double? productDiscountedPrice = convertWithDiscount(
  //     price,
  //     productDiscount,
  //     productDiscountType,
  //   );
  //
  //   // If no category discount, return product discount
  //   if (categoryDiscountedPrice == null || categoryDiscountedPrice == price) {
  //     return productDiscountedPrice;
  //   }
  //
  //   // If category discount is greater than price, use product discount
  //   if ((price! - categoryDiscountedPrice) >= price) {
  //     return productDiscountedPrice;
  //   }
  //
  //   // Return the price with higher discount
  //   return categoryDiscountedPrice < productDiscountedPrice! ? categoryDiscountedPrice : productDiscountedPrice;
  // }
}
