import '../common/models/cart_model.dart';
import '../common/models/product_model.dart';
import '../helper/price_converter_helper.dart';

class CartHelper {
  static CartModel? getCartModel(
    Product product, {
    List<int>? variationIndexList,
    int? quantity,
  }) {
    CartModel? cartModel;
    Variations? variation;

    int? stock = 0;
    List variationList = [];

    double? price = product.price;
    stock = product.totalStock;
    double? priceWithDiscount;

    for (int index = 0; index < (product.choiceOptions?.length ?? 0); index++) {
      final options = product.choiceOptions?[index].options;
      if (options != null && options.isNotEmpty) {
        if (variationIndexList != null &&
            variationIndexList.length > index &&
            variationIndexList[index] >= 0 &&
            variationIndexList[index] < options.length) {
          variationList.add(
            options[variationIndexList[index]].replaceAll(' ', ''),
          );
        } else {
          variationList.add(
            options[0].replaceAll(' ', ''),
          );
        }
      }
    }

    String variationType = '';
    bool isFirst = true;
    for (var variation in variationList) {
      if (isFirst) {
        variationType = '$variationType$variation';
        isFirst = false;
      } else {
        variationType = '$variationType-$variation';
      }
    }

    for (Variations variationValue in product.variations ?? []) {
      if (variationValue.type == variationType ||
          variationValue.type?.replaceAll(' ', '') == variationType.replaceAll(' ', '')) {
        price = (variationValue.price != null && variationValue.price! > 0)
            ? variationValue.price
            : product.price;
        variation = variationValue;
        stock = variationValue.stock;
        break;
      }
    }

    if (price == null || price <= 0) {
      price = product.price ?? 0.0;
    }

    if (stock == null || stock <= 0) {
      if (product.totalStock != null && product.totalStock! > 0) {
        stock = product.totalStock;
      }
    }

    priceWithDiscount = PriceConverterHelper.convertProductDiscount(
      price: price,
      discount: product.discount,
      discountType: product.discountType,
      categoryDiscount: product.categoryDiscount,
    ).discount;

    cartModel = CartModel(
      product.id,
      (product.image?.isNotEmpty ?? false) ? product.image![0] : '',
      product.name,
      price,
      priceWithDiscount,
      quantity,
      variation,
      (price - (priceWithDiscount ?? 0)),
      ((priceWithDiscount ?? 0) -
          PriceConverterHelper.convertWithDiscount(
            priceWithDiscount,
            product.tax,
            product.taxType,
          )!),
      product.capacity,
      product.unit,
      stock,
      product,
    );

    return cartModel;
  }

  static double weightCalculation(List<CartModel> cartList) {
    double sum = 0.0;
    for (CartModel item in cartList) {
      sum +=
          (item.product?.weight?.toDouble() ?? 0.0) *
          (item.quantity?.toInt() ?? 1.0);
    }
    return sum;
  }
}
