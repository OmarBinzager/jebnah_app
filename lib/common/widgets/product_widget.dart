import 'package:flutter/material.dart';
import '../../../../common/models/cart_model.dart';
import '../../../../common/models/product_model.dart';
import '../../../../helper/price_converter_helper.dart';
import '../../../../utill/product_type.dart';
import '../../../../helper/route_helper.dart';
import '../../../../localization/app_localization.dart';
import '../../../../localization/language_constraints.dart';
import '../../../../common/providers/cart_provider.dart';
import '../../../../features/splash/providers/splash_provider.dart';

import '../../../../utill/dimensions.dart';
import '../../../../utill/styles.dart';
import '../../../../common/widgets/custom_directionality_widget.dart';
import '../../../../common/widgets/custom_image_widget.dart';
import '../../../../helper/custom_snackbar_helper.dart';
import '../../../../common/widgets/on_hover_widget.dart';
import 'package:provider/provider.dart';

import 'wish_button_widget.dart';

class ProductWidget extends StatelessWidget {
  final Product product;
  final String productType;
  final bool isGrid;
  final bool isCenter;
  const ProductWidget({
    super.key,
    required this.product,
    this.productType = ProductType.dailyItem,
    this.isGrid = false,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final discountValue = PriceConverterHelper.convertProductDiscount(
      price: product.price,
      discount: product.discount,
      discountType: product.discountType,
      categoryDiscount: product.categoryDiscount,
    );
    final double? priceWithDiscount = discountValue.discount;
    final brandImageUrl =
        product.brand?.image != null && product.brand!.image!.isNotEmpty
        ? '${Provider.of<SplashProvider>(context, listen: false).baseUrls?.brandImageUrl}/${product.brand!.image}'
        : '';
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        double price = 0;
        int? stock = 0;
        bool isExistInCart = false;
        int? cardIndex;
        CartModel? cartModel;

        if (product.variations!.isNotEmpty) {
          for (int index = 0; index < product.variations!.length; index++) {
            price = product.variations!.isNotEmpty
                ? (product.variations![index].price ?? 0)
                : (product.price ?? 0);
            stock = product.variations!.isNotEmpty
                ? product.variations![index].stock
                : product.totalStock;
            cartModel = CartModel(
              product.id,
              product.image!.isNotEmpty ? product.image![0] : '',
              product.name,
              price,
              discountValue.discount,
              1,
              product.variations!.isNotEmpty
                  ? product.variations![index]
                  : null,
              (price - (discountValue.discount ?? 0)),
              ((discountValue.discount ?? 0) -
                  PriceConverterHelper.convertWithDiscount(
                    discountValue.discount,
                    product.tax,
                    product.taxType,
                  )!),
              product.capacity,
              product.unit,
              stock,
              product,
            );
            isExistInCart = cartProvider.isExistInCart(cartModel) != null;
            cardIndex = cartProvider.isExistInCart(cartModel);

            if (isExistInCart) {
              break;
            }
          }
        } else {
          price = product.price ?? 0;
          stock = product.totalStock;
          cartModel = CartModel(
            product.id,
            (product.image?.isNotEmpty ?? false) ? product.image![0] : '',
            product.name,
            price,
            discountValue.discount,
            1,
            null,
            (price - (discountValue.discount ?? 0)),
            ((discountValue.discount ?? 0) -
                PriceConverterHelper.convertWithDiscount(
                  discountValue.discount,
                  product.tax,
                  product.taxType,
                )!),
            product.capacity,
            product.unit,
            stock,
            product,
          );

          isExistInCart = cartProvider.isExistInCart(cartModel) != null;
          cardIndex = cartProvider.isExistInCart(cartModel);
        }

        final bool hasNotVariations =
            product.variations == null ||
            (product.variations?.isEmpty ?? false);

        return isGrid
            ? OnHoverWidget(
                isItem: true,
                child: _ProductGridWidget(
                  cardIndex: cardIndex,
                  isCenter: isCenter,
                  isExistInCart: isExistInCart,
                  priceWithDiscount: priceWithDiscount ?? 0,
                  discountType: discountValue.type,
                  product: product,
                  productType: productType,
                  cartModel: cartModel,
                  stock: stock,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeSmall,
                ),
                child: InkWell(
                  hoverColor: Colors.transparent,
                  onTap: () => RouteHelper.getProductDetailsRoute(
                    productId: product.id,
                    formSearch: productType == ProductType.searchItem,
                  ),
                  child: OnHoverWidget(
                    isItem: true,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Product Image Section
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: CustomImageWidget(
                                  image:
                                      '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${product.image!.isNotEmpty ? product.image![0] : ''}',
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              // Warranty Badge - Bottom Left inside image
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '3 ضمان',
                                        style: poppinsMedium.copyWith(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Discount Tag - Bottom Left inside image (next to warranty)
                              if (product.price != discountValue.discount)
                                Positioned(
                                  bottom: 8,
                                  left: 70,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B35),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      '% ${_getDiscountPercentage(product, discountValue)}',
                                      style: poppinsBold.copyWith(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                              // Wish Button - Top Right inside image
                              Positioned(
                                top: 8,
                                right: 8,
                                child: WishButtonWidget(
                                  product: product,
                                  edgeInset: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),

                          // Brand Logo - Below Image (outside image)
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Theme.of(context).cardColor,
                                  width: 2,
                                ),
                                color: Colors.white,
                              ),
                              child: ClipOval(
                                child: CustomImageWidget(
                                  image: brandImageUrl,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          // Product Details Section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Product Name - Made clearer
                                Text(
                                  product.name ?? '',
                                  style: poppinsBold.copyWith(
                                    fontSize: 15,
                                    height: 1.3,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 8),

                                // Price Section - Made clearer
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Current Price (after discount)
                                    CustomDirectionalityWidget(
                                      child: Text(
                                        PriceConverterHelper.convertPrice(
                                          context,
                                          priceWithDiscount,
                                        ),
                                        style: poppinsExtraBold.copyWith(
                                          fontSize: 20,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Original Price (before discount)
                                    if ((product.price ?? 0) >
                                        priceWithDiscount!)
                                      Flexible(
                                        child: CustomDirectionalityWidget(
                                          child: Text(
                                            PriceConverterHelper.convertPrice(
                                              context,
                                              product.price,
                                            ),
                                            style: poppinsRegular.copyWith(
                                              fontSize: 12,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Theme.of(
                                                context,
                                              ).disabledColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Add to Cart Button - Full width
                                _buildAddToCartButton(
                                  context: context,
                                  isExistInCart: isExistInCart,
                                  hasNotVariations: hasNotVariations,
                                  stock: stock,
                                  cartModel: cartModel,
                                  cardIndex: cardIndex,
                                  product: product,
                                  productType: productType,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }

  String _getDiscountPercentage(Product product, dynamic discountValue) {
    if (discountValue.type == DiscountType.productDiscount) {
      if (product.discountType == 'percent') {
        return product.discount.toString();
      } else {
        double originalPrice = product.price ?? 0;
        double discountedPrice = discountValue.discount ?? 0;
        if (originalPrice > 0) {
          int percentage =
              ((originalPrice - discountedPrice) / originalPrice * 100).round();
          return percentage.toString();
        }
        return '0';
      }
    } else {
      if (product.categoryDiscount?.discountType == 'percent') {
        return product.categoryDiscount?.discountAmount.toString() ?? '0';
      } else {
        double originalPrice = product.price ?? 0;
        double discountedPrice = discountValue.discount ?? 0;
        if (originalPrice > 0) {
          int percentage =
              ((originalPrice - discountedPrice) / originalPrice * 100).round();
          return percentage.toString();
        }
        return '0';
      }
    }
  }

  Widget _buildAddToCartButton({
    required BuildContext context,
    required bool isExistInCart,
    required bool hasNotVariations,
    required int? stock,
    required CartModel? cartModel,
    required int? cardIndex,
    required Product product,
    required String productType,
  }) {
    final bool canAddToCart = !isExistInCart || !hasNotVariations;

    if (!canAddToCart) {
      return Consumer<CartProvider>(
        builder: (context, cart, child) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  if (cart.cartList[cardIndex!].quantity! > 1) {
                    Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).setCartQuantity(
                      false,
                      cardIndex,
                      context: context,
                      showMessage: true,
                    );
                  } else {
                    Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).removeItemFromCart(cardIndex, context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                cart.cartList[cardIndex!].quantity.toString(),
                style: poppinsSemiBold.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              InkWell(
                onTap: () {
                  if (cart.cartList[cardIndex].quantity! <
                      cart.cartList[cardIndex].stock!) {
                    cart.setCartQuantity(
                      true,
                      cardIndex,
                      showMessage: false,
                      context: context,
                    );
                  } else {
                    showCustomSnackBarHelper(
                      getTranslated(
                        'there_is_nt_enough_quantity_on_stock',
                        context,
                      ),
                      snackBarStatus: SnackBarStatus.info,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.black),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (product.variations == null || product.variations!.isEmpty) {
            if (isExistInCart) {
              showCustomSnackBarHelper('already_added'.tr);
            } else if (stock! < 1) {
              showCustomSnackBarHelper(
                getTranslated('there_is_nt_enough_quantity_on_stock', context),
                snackBarStatus: SnackBarStatus.info,
              );
            } else {
              Provider.of<CartProvider>(
                context,
                listen: false,
              ).addToCart(cartModel!);
              showCustomSnackBarHelper('added_to_cart'.tr, isError: false);
            }
          } else {
            RouteHelper.getProductDetailsRoute(
              productId: product.id,
              formSearch: productType == ProductType.searchItem,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          minimumSize: const Size(0, 40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 18),
            const SizedBox(width: 8),
            Text(
              getTranslated('add_to_cart', context),
              style: poppinsSemiBold.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// Product Grid Widget - مع التعديلات المطلوبة
class _ProductGridWidget extends StatelessWidget {
  final bool isExistInCart;
  final int? stock;
  final CartModel? cartModel;
  final int? cardIndex;
  final double priceWithDiscount;
  final DiscountType? discountType;
  final Product product;
  final String productType;
  final bool isCenter;

  const _ProductGridWidget({
    required this.isExistInCart,
    this.stock,
    this.cartModel,
    required this.cardIndex,
    required this.priceWithDiscount,
    required this.product,
    required this.productType,
    required this.isCenter,
    required this.discountType,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasNotVariations =
        product.variations == null || (product.variations?.isEmpty ?? false);

    // الحصول على رابط صورة البراند
    final brandImageUrl =
        product.brand?.image != null && product.brand!.image!.isNotEmpty
        ? '${Provider.of<SplashProvider>(context, listen: false).baseUrls?.brandImageUrl}/${product.brand!.image}'
        : '';

    return SizedBox(
      width: 260,
      height: 330, // ارتفاع ثابت للبطاقة
      child: InkWell(
        hoverColor: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          RouteHelper.getProductDetailsRoute(
            productId: product.id,
            formSearch: productType == ProductType.searchItem,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CustomImageWidget(
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 160,
                      image:
                          '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${(product.image?.isNotEmpty ?? false) ? product.image![0] : ''}',
                    ),
                  ),

                  // Discount Tag - Top Left
                  if (product.price != priceWithDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '% ${_getDiscountPercentage()}',
                          style: poppinsBold.copyWith(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // Warranty Badge - Bottom Left inside image
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '3 ضمان',
                            style: poppinsMedium.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Wish Button - Top Right inside image
                  Positioned(
                    top: 8,
                    right: 8,
                    child: WishButtonWidget(
                      product: product,
                      edgeInset: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              // Brand Logo - Below Image (غير دائري - بشكل مستطيل)
              Align(
                alignment: Alignment.center,
                child: Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 50,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Theme.of(context).cardColor,
                      width: 1,
                    ),
                    color: Colors.white,
                  ),
                  child: brandImageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CustomImageWidget(
                            image: brandImageUrl,
                            fit: BoxFit.contain,
                          ),
                        )
                      : const Icon(Icons.store, size: 20),
                ),
              ),

              // Product Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Name - Made clearer
                      Flexible(
                        child: Text(
                          product.name ?? '',
                          style: poppinsBold.copyWith(
                            fontSize: 13,
                            height: 1.3,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Price Section - Made clearer
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Current Price
                          Flexible(
                            child: CustomDirectionalityWidget(
                              child: Text(
                                PriceConverterHelper.convertPrice(
                                  context,
                                  priceWithDiscount,
                                ),
                                style: poppinsExtraBold.copyWith(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Original Price
                          if ((product.price ?? 0) > priceWithDiscount)
                            Flexible(
                              child: CustomDirectionalityWidget(
                                child: Text(
                                  PriceConverterHelper.convertPrice(
                                    context,
                                    product.price,
                                  ),
                                  style: poppinsRegular.copyWith(
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Add to Cart Button - Full width (no wish button in same row)
                      _buildAddToCartButton(
                        context: context,
                        isExistInCart: isExistInCart,
                        hasNotVariations: hasNotVariations,
                        stock: stock,
                        cartModel: cartModel,
                        cardIndex: cardIndex,
                        product: product,
                        productType: productType,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDiscountPercentage() {
    if (discountType == DiscountType.productDiscount) {
      if (product.discountType == 'percent') {
        return product.discount.toString();
      } else {
        double originalPrice = product.price ?? 0;
        double discountedPrice = priceWithDiscount;
        if (originalPrice > 0) {
          int percentage =
              ((originalPrice - discountedPrice) / originalPrice * 100).round();
          return percentage.toString();
        }
        return '0';
      }
    } else {
      if (product.categoryDiscount?.discountType == 'percent') {
        return product.categoryDiscount?.discountAmount.toString() ?? '0';
      } else {
        double originalPrice = product.price ?? 0;
        double discountedPrice = priceWithDiscount;
        if (originalPrice > 0) {
          int percentage =
              ((originalPrice - discountedPrice) / originalPrice * 100).round();
          return percentage.toString();
        }
        return '0';
      }
    }
  }

  Widget _buildAddToCartButton({
    required BuildContext context,
    required bool isExistInCart,
    required bool hasNotVariations,
    required int? stock,
    required CartModel? cartModel,
    required int? cardIndex,
    required Product product,
    required String productType,
  }) {
    final bool canAddToCart = !isExistInCart || !hasNotVariations;

    if (!canAddToCart) {
      return Consumer<CartProvider>(
        builder: (context, cart, child) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  if (cart.cartList[cardIndex!].quantity! > 1) {
                    Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).setCartQuantity(
                      false,
                      cardIndex,
                      context: context,
                      showMessage: true,
                    );
                  } else {
                    Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).removeItemFromCart(cardIndex, context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                cart.cartList[cardIndex!].quantity.toString(),
                style: poppinsSemiBold.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              InkWell(
                onTap: () {
                  if (cart.cartList[cardIndex].quantity! <
                      cart.cartList[cardIndex].stock!) {
                    cart.setCartQuantity(
                      true,
                      cardIndex,
                      showMessage: false,
                      context: context,
                    );
                  } else {
                    showCustomSnackBarHelper(
                      getTranslated(
                        'there_is_nt_enough_quantity_on_stock',
                        context,
                      ),
                      snackBarStatus: SnackBarStatus.info,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 14, color: Colors.black),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (product.variations == null || product.variations!.isEmpty) {
            if (isExistInCart) {
              showCustomSnackBarHelper('already_added'.tr);
            } else if (stock! < 1) {
              showCustomSnackBarHelper(
                getTranslated('there_is_nt_enough_quantity_on_stock', context),
                snackBarStatus: SnackBarStatus.info,
              );
            } else {
              Provider.of<CartProvider>(
                context,
                listen: false,
              ).addToCart(cartModel!);
              showCustomSnackBarHelper('added_to_cart'.tr, isError: false);
            }
          } else {
            RouteHelper.getProductDetailsRoute(
              productId: product.id,
              formSearch: productType == ProductType.searchItem,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          minimumSize: const Size(0, 38),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                getTranslated('add_to_cart', context),
                style: poppinsSemiBold.copyWith(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
