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
      if (sharedPreferences?.containsKey(AppConstants.cartList) ?? false) {
        carts = sharedPreferences?.getStringList(AppConstants.cartList);
      }
      if (carts != null) {
        for (var cart in carts) {
          try {
            cartList.add(CartModel.fromJson(jsonDecode(cart)));
          } catch (e) {
            // Ignore corrupted single item, do not wipe entire cart
          }
        }
      }
    } catch (e) {
      // Do not clear shared preferences on read error
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
