import 'dart:convert';

import '../../../../common/models/cart_model.dart';
import '../../../../utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepo {
  final SharedPreferences? sharedPreferences;
  CartRepo({required this.sharedPreferences});

  List<CartModel> getCartList() {
    List<String>? carts = [];
    List<CartModel> cartList = [];
    try {
      if (sharedPreferences!.containsKey(AppConstants.cartList)) {
        carts = sharedPreferences!.getStringList(AppConstants.cartList);
      }
      for (var cart in carts!) {
        cartList.add(CartModel.fromJson(jsonDecode(cart)));
      }
    } catch (e) {
      sharedPreferences?.clear();
    }
    return cartList;
  }

  void addToCartList(List<CartModel> cartProductList) {
    List<String> carts = [];
    for (var cartModel in cartProductList) {
      carts.add(jsonEncode(cartModel));
    }
    sharedPreferences!.setStringList(AppConstants.cartList, carts);
  }
}
