import 'package:flutter/material.dart';
import '../../../../common/models/cart_model.dart';
import '../../../../common/models/product_model.dart';
import '../../../../common/reposotories/cart_repo.dart';
import '../../../../localization/app_localization.dart';
import '../../../../helper/custom_snackbar_helper.dart';

class CartProvider extends ChangeNotifier {
  final CartRepo? cartRepo;
  CartProvider({required this.cartRepo});

  int _productSelect = 0;
  List<CartModel> _cartList = [];
  final List<CartModel> _pendingCartList = [];
  List<CartModel> get updatedCartList =>
      _pendingCartList.isEmpty ? _cartList : _pendingCartList;
  double _amount = 0.0;
  int? _cartIndex;
  int _quantity = 1;
  List<int>? _variationIndex;

  int get productSelect => _productSelect;
  List<CartModel> get cartList => _cartList;
  List<CartModel> get pendingCartList => _pendingCartList;
  double get amount => _amount;
  int? get cartIndex => _cartIndex;
  int get quantity => _quantity;
  List<int>? get variationIndex => _variationIndex;

  void getCartData({bool isUpdate = false}) {
    _cartList = [];
    _pendingCartList.clear();
    _amount = 0.0;
    _cartList.addAll(cartRepo!.getCartList());
    for (var cart in _cartList) {
      _amount = _amount + (cart.discountedPrice! * cart.quantity!);
    }
    if (isUpdate) {
      notifyListeners();
    }
  }

  void onSelectProductStatus(int select, bool isNotify) {
    _productSelect = select;
    if (isNotify) {
      notifyListeners();
    }
  }

  void addToCart(CartModel cartModel) {
    _cartList.add(cartModel);
    cartRepo?.addToCartList(_cartList);
    _amount = _amount + (cartModel.discountedPrice! * cartModel.quantity!);
    notifyListeners();
  }

  void setCartQuantity(
    bool isIncrement,
    int? index, {
    bool showMessage = false,
    BuildContext? context,
  }) {
    if (isIncrement) {
      _cartList[index!].quantity = _cartList[index].quantity! + 1;
      _amount = _amount + _cartList[index].discountedPrice!;
      if (showMessage) {
        showCustomSnackBarHelper(
          'quantity_increase_from_cart'.tr,
          isError: false,
        );
      }
    } else {
      _cartList[index!].quantity = _cartList[index].quantity! - 1;
      _amount = _amount - _cartList[index].discountedPrice!;
      if (showMessage) {
        showCustomSnackBarHelper('quantity_decreased_from_cart'.tr);
      }
    }
    cartRepo!.addToCartList(_cartList);

    notifyListeners();
  }

  void initialUpdateCartQuantity(
    bool isIncrement,
    int? index, {
    bool showMessage = false,
    BuildContext? context,
  }) {
    if (_pendingCartList.isEmpty) {
      _pendingCartList.addAll(
        _cartList.map((item) => item.copyWith()).toList(),
      );
    }

    if (isIncrement) {
      _pendingCartList[index!].quantity = _pendingCartList[index].quantity! + 1;
      _amount = _amount + _pendingCartList[index].discountedPrice!;
      if (showMessage) {
        showCustomSnackBarHelper(
          'quantity_increase_from_details'.tr,
          isError: false,
        );
      }
    } else {
      _pendingCartList[index!].quantity = _pendingCartList[index].quantity! - 1;
      _amount = _amount - _pendingCartList[index].discountedPrice!;
      if (showMessage) {
        showCustomSnackBarHelper(
          'quantity_decreased_from_details'.tr,
          isError: false,
        );
      }
    }

    notifyListeners();
  }

  void updateCart() {
    _cartList = _pendingCartList.map((item) => item.copyWith()).toList();
    _pendingCartList.clear();
    cartRepo!.addToCartList(_cartList);

    notifyListeners();
  }

  void removeItemFromCart(int index, BuildContext context) {
    _amount =
        _amount -
        (cartList[index].discountedPrice! * cartList[index].quantity!);
    showCustomSnackBarHelper('remove_from_cart'.tr);
    _cartList.removeAt(index);
    cartRepo!.addToCartList(_cartList);
    _quantity = 1;
    notifyListeners();
  }

  void clearCartList() {
    _cartList = [];
    _amount = 0;
    cartRepo!.addToCartList(_cartList);
    notifyListeners();
  }

  int? isExistInCart(CartModel? cartModel) {
    for (int index = 0; index < _cartList.length; index++) {
      if (_cartList[index].id == cartModel?.id) {
        if ((_cartList[index].variation == null
            ? true
            : _cartList[index].variation?.type == cartModel?.variation?.type)) {
          return index;
        }
      }
    }
    return null;
  }

  void setExistData(int? cartIndex) {
    _cartIndex = cartIndex;
  }

  void initData(Product product) {
    _variationIndex = [];
    _cartIndex = null;
    _quantity = 1;
    if (product.choiceOptions != null) {
      for (int i = 0; i < product.choiceOptions!.length; i++) {
        _variationIndex!.add(0);
      }
    }
  }

  void setQuantity(bool isIncrement) {
    if (isIncrement) {
      _quantity = _quantity + 1;
    } else {
      _quantity = _quantity - 1;
    }
    notifyListeners();
  }

  void setCartVariationIndex(int index, int i) {
    _variationIndex![index] = i;
    _pendingCartList.clear();
    _quantity = 1;
    notifyListeners();
  }

  int getTotalCartQuantity() {
    int total = 0;
    for (CartModel cart in _cartList) {
      total += cart.quantity!;
    }
    return total;
  }

  int getCartQuantityByProductId(int productId) {
    int total = 0;
    for (CartModel cart in _cartList) {
      if (cart.id == productId) {
        total += cart.quantity!;
      }
    }
    return total;
  }
}
