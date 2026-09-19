import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../common/models/cart_model.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../common/providers/theme_provider.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../common/widgets/custom_tooltip.dart';
import '../../../features/cart/widgets/discounted_price_widget.dart';
import '../../../features/coupon/providers/coupon_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class CartItemWidget extends StatelessWidget {
  final ScrollController? scrollController;
  final CartModel cart;
  final int index;
  const CartItemWidget({
    super.key,
    required this.cart,
    required this.index,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final CartProvider cartProvider = Provider.of<CartProvider>(
      context,
      listen: false,
    );
    String? variationText = _getVariationValue();

    final GlobalKey<CustomTooltipState> tooltipKey =
        GlobalKey<CustomTooltipState>();

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          RouteHelper.getProductDetailsRoute(productId: cart.product?.id);
        },
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: 0,
              child: Icon(Icons.delete, color: Colors.white, size: 50),
            ),
            Dismissible(
              key: UniqueKey(),
              onDismissed: (DismissDirection direction) {
                cartProvider.setExistData(null);
                Provider.of<CouponProvider>(
                  context,
                  listen: false,
                ).removeCouponData(false);
                cartProvider.removeItemFromCart(index, context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                  horizontal: Dimensions.paddingSizeSmall,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.grey[Provider.of<ThemeProvider>(
                                context,
                              ).darkTheme
                              ? 900
                              : 200]!,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: ResponsiveHelper.isDesktop(context)
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  mainAxisAlignment: ResponsiveHelper.isDesktop(context)
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.05),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomImageWidget(
                          image:
                              '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${cart.image}',
                          height: ResponsiveHelper.isDesktop(context)
                              ? 100
                              : 70,
                          width: ResponsiveHelper.isDesktop(context) ? 100 : 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    !ResponsiveHelper.isDesktop(context)
                        ? Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cart.name!,
                                  style: poppinsMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall,
                                ),

                                if (cart.product?.variations?.isNotEmpty ??
                                    false)
                                  Row(
                                    children: [
                                      Text(
                                        '${getTranslated('variation', context)}: ',
                                        style: poppinsRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),

                                      Flexible(
                                        child: Text(
                                          variationText!,
                                          style: poppinsRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(
                                              context,
                                            ).disabledColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                Text(
                                  '${cart.capacity} ${cart.unit}',
                                  style: poppinsMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall,
                                ),

                                DiscountedPriceWidget(
                                  cart: cart,
                                  leadingText:
                                      '${getTranslated('unit', context)}: ',
                                ),

                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall,
                                ),

                                DiscountedPriceWidget(
                                  cart: cart,
                                  isUnitPrice: false,
                                  leadingText:
                                      '${getTranslated('total', context)}: ',
                                ),
                              ],
                            ),
                          )
                        : Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cart.name ?? '',
                                        style: poppinsRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),

                                      if (cart
                                              .product
                                              ?.variations
                                              ?.isNotEmpty ??
                                          false)
                                        Wrap(
                                          children: [
                                            Text(
                                              '${getTranslated('variation', context)}: ',
                                              style: poppinsRegular.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall,
                                              ),
                                            ),

                                            Text(
                                              variationText!,
                                              style: poppinsRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(
                                                  context,
                                                ).disabledColor,
                                              ),
                                            ),
                                          ],
                                        ),

                                      DiscountedPriceWidget(
                                        cart: cart,
                                        leadingText:
                                            '${getTranslated('unit', context)}: ',
                                      ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeLarge,
                                ),

                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    children: [
                                      Text(
                                        '${cart.capacity} ${cart.unit}',
                                        style: poppinsMedium.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeDefault,
                                      ),

                                      DiscountedPriceWidget(
                                        cart: cart,
                                        isUnitPrice: false,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),
                              ],
                            ),
                          ),

                    RotatedBox(
                      quarterTurns: ResponsiveHelper.isMobile() ? 0 : 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeExtraSmall,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).disabledColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTooltip(
                              scrollController: scrollController,
                              key: tooltipKey,
                              title: getTranslated('warning', context),
                              description:
                                  (cart.product!.maximumOrderQuantity == null ||
                                      cart.quantity! >=
                                          cart.product!.maximumOrderQuantity!)
                                  ? '${getTranslated('you_cant_add_more_than', context)} ${cart.product!.maximumOrderQuantity!} '
                                        '${getTranslated(cart.product!.maximumOrderQuantity! > 1 ? 'items' : 'item', context)}'
                                  : '${getTranslated('there_is_nt_enough_quantity_on_stock', context)} ${getTranslated('only', context)} ${cart.stock} ${getTranslated('is_available', context)}',
                              toolTipGap:
                                  (cart.product!.maximumOrderQuantity == null ||
                                      cart.quantity! >=
                                          cart.product!.maximumOrderQuantity!)
                                  ? 15
                                  : 25,
                              leftOffset: -45,
                              leadingIcon: Icons.warning,
                              iconColor: Colors.orange,
                              placement: TooltipPlacement.top,
                              tailPosition: TooltipTailPosition.start,
                              backgroundColor: Colors.orange.withValues(
                                alpha: 0.08,
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (cart.product!.maximumOrderQuantity ==
                                          null ||
                                      cart.quantity! <
                                          cart.product!.maximumOrderQuantity!) {
                                    if (cart.quantity! < cart.stock!) {
                                      Provider.of<CouponProvider>(
                                        context,
                                        listen: false,
                                      ).removeCouponData(false);
                                      cartProvider.setCartQuantity(
                                        true,
                                        index,
                                        showMessage: false,
                                        context: context,
                                      );
                                    } else {
                                      ResponsiveHelper.isDesktop(context)
                                          ? tooltipKey.currentState
                                                ?.showTooltip(context)
                                          : showCustomSnackBarHelper(
                                              '${getTranslated('there_is_nt_enough_quantity_on_stock', context)} ${getTranslated('only', context)} ${cart.stock} '
                                              '${getTranslated('is_available', context)}',
                                              snackBarStatus:
                                                  SnackBarStatus.info,
                                            );
                                    }
                                  } else {
                                    ResponsiveHelper.isDesktop(context)
                                        ? tooltipKey.currentState?.showTooltip(
                                            context,
                                          )
                                        : showCustomSnackBarHelper(
                                            '${getTranslated('you_cant_add_more_than', context)} ${cart.product!.maximumOrderQuantity} '
                                            '${getTranslated(cart.product!.maximumOrderQuantity! > 1 ? 'items' : 'item', context)}',
                                          );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(
                                    Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 12,
                                    color: Theme.of(context).cardColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveHelper.isMobile()
                                  ? Dimensions.paddingSizeExtraSmall
                                  : Dimensions.paddingSizeSmall,
                            ),

                            RotatedBox(
                              quarterTurns: ResponsiveHelper.isMobile() ? 0 : 3,
                              child: Text(
                                cart.quantity.toString(),
                                style: poppinsSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveHelper.isMobile()
                                  ? Dimensions.paddingSizeExtraSmall
                                  : Dimensions.paddingSizeSmall,
                            ),

                            RotatedBox(
                              quarterTurns: ResponsiveHelper.isMobile() ? 0 : 1,
                              child:
                                  (ResponsiveHelper.isDesktop(context) &&
                                      cart.quantity == 1)
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        left: Dimensions.paddingSizeSmall,
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          cartProvider.removeItemFromCart(
                                            index,
                                            context,
                                          );
                                          cartProvider.setExistData(null);
                                        },
                                        icon: const RotatedBox(
                                          quarterTurns: 2,
                                          child: Icon(
                                            CupertinoIcons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        Provider.of<CouponProvider>(
                                          context,
                                          listen: false,
                                        ).removeCouponData(false);
                                        if (cart.quantity! > 1) {
                                          cartProvider.setCartQuantity(
                                            false,
                                            index,
                                            showMessage: false,
                                            context: context,
                                          );
                                        } else if (cart.quantity == 1) {
                                          cartProvider.removeItemFromCart(
                                            index,
                                            context,
                                          );
                                          cartProvider.setExistData(null);
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).canvasColor,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(
                                          Dimensions.paddingSizeExtraSmall,
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          size: 12,
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getVariationValue() {
    String? variationText = '';
    if (cart.variation != null) {
      List<String> variationTypes = cart.variation?.type?.split('-') ?? [];
      if (variationTypes.length == cart.product?.choiceOptions?.length) {
        int index = 0;
        for (var choice in cart.product?.choiceOptions ?? []) {
          variationText =
              '$variationText${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
          index = index + 1;
        }
      } else {
        variationText = cart.product?.variations?[0].type;
      }
    }

    return variationText;
  }
}
