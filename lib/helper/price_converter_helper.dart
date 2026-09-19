import 'package:flutter/material.dart';
import '../common/models/config_model.dart';
import '../common/models/product_model.dart';
import '../features/splash/providers/splash_provider.dart';
import 'package:provider/provider.dart';

class PriceConverterHelper {
  static String convertPrice(
    BuildContext context,
    double? price, {
    double? discount,
    String? discountType,
  }) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = price! - discount;
      } else if (discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }
    ConfigModel config = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel!;
    bool isLeft = config.currencySymbolPosition == 'left';
    return !isLeft
        ? '${price!.toStringAsFixed(config.decimalPointSettings!).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
              ' ${config.currencySymbol}'
        : '${config.currencySymbol} '
              '${price!.toStringAsFixed(config.decimalPointSettings!).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
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
    return '$discount${discountType == 'percent' ? '%' : '${Provider.of<SplashProvider>(context, listen: false).configModel!.currencySymbol}'} OFF';
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
