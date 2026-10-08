import 'package:flutter/material.dart';
import '../../../common/widgets/price_item_widget.dart';
import '../../../features/cart/widgets/coupon_widget.dart';
import '../../../features/cart/widgets/delivery_option_widget.dart';
import '../../../features/coupon/providers/coupon_provider.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/price_converter_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class CartDetailsWidget extends StatelessWidget {
  const CartDetailsWidget({
    super.key,
    required TextEditingController couponController,
    required double total,
    required bool isFreeDelivery,
    required double itemPrice,
    required double tax,
    required double discount,
  }) : _couponController = couponController,
       _total = total,
       _isFreeDelivery = isFreeDelivery,
       _itemPrice = itemPrice,
       _tax = tax,
       _discount = discount;

  final TextEditingController _couponController;
  final double _total;
  final bool _isFreeDelivery;
  final double _itemPrice;
  final double _tax;
  final double _discount;

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel!;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated('delivery_option', context),
                style: poppinsSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),

              Divider(
                color: Theme.of(context).hintColor.withValues(alpha: 0.1),
              ),

              Consumer<OrderProvider>(
                builder: (context, orderProvider, _) {
                  final splashProvider =
                      Provider.of<SplashProvider>(context, listen: false);
                  final setup = (splashProvider.deliveryInfoModelList != null &&
                          splashProvider.deliveryInfoModelList!.isNotEmpty &&
                          orderProvider.branchIndex <
                              splashProvider.deliveryInfoModelList!.length)
                      ? splashProvider
                          .deliveryInfoModelList![orderProvider.branchIndex]
                          .deliveryChargeSetup
                      : null;

                  double convenientPrice = 0.0;
                  double fastPrice = 0.0;

                  if (setup?.deliveryChargeType == 'fixed') {
                    convenientPrice =
                        setup?.convenientDeliveryCharge?.toDouble() ?? 0.0;
                    fastPrice = setup?.fastDeliveryCharge?.toDouble() ??
                        (setup?.fixedDeliveryCharge?.toDouble() ??
                            (configModel.deliveryCharge ?? 0.0));
                  } else {
                    fastPrice = setup?.minimumDeliveryCharge?.toDouble() ??
                        (configModel.deliveryCharge ?? 0.0);
                  }

                  String convenientPriceStr = convenientPrice <= 0
                      ? getTranslated('free', context)
                      : PriceConverterHelper.convertPrice(context, convenientPrice);
                  String fastPriceStr = fastPrice <= 0
                      ? getTranslated('free', context)
                      : PriceConverterHelper.convertPrice(context, fastPrice);

                  return Row(
                    children: [
                      Expanded(
                        child: DeliveryOptionWidget(
                          value: 'delivery',
                          title: getTranslated('fast_delivery', context),
                          subTitle: fastPriceStr,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: DeliveryOptionWidget(
                          value: 'self_pickup',
                          title: getTranslated('convenient_delivery', context),
                          subTitle: convenientPriceStr,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<CouponProvider>(
                builder: (context, couponProvider, child) {
                  return CouponWidget(
                    couponController: _couponController,
                    discountedPrice: _itemPrice - _discount,
                  );
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              PriceItemWidget(
                title: getTranslated('subtotal', context),
                subTitle: PriceConverterHelper.convertPrice(
                  context,
                  _itemPrice,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              PriceItemWidget(
                title: getTranslated('discount', context),
                subTitle:
                    '- ${PriceConverterHelper.convertPrice(context, _discount)}',
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              PriceItemWidget(
                title:
                    '${getTranslated('tax', context)} ${configModel.isVatTexInclude! ? '(${getTranslated('include', context)})' : ''}',
                subTitle:
                    '${configModel.isVatTexInclude! ? '' : '+'} ${PriceConverterHelper.convertPrice(context, _tax)}',
              ),

              Consumer<CouponProvider>(
                builder: (context, couponProvider, _) {
                  return couponProvider.coupon?.couponType != 'free_delivery' &&
                          couponProvider.discount! > 0
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            vertical:
                                couponProvider.coupon?.couponType !=
                                        'free_delivery' &&
                                    couponProvider.discount! > 0
                                ? Dimensions.paddingSizeSmall
                                : 0,
                          ),
                          child: PriceItemWidget(
                            title: getTranslated('coupon_discount', context),
                            subTitle:
                                '- ${PriceConverterHelper.convertPrice(context, couponProvider.discount)}',
                          ),
                        )
                      : const SizedBox();
                },
              ),

              Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  final SplashProvider splashProvider =
                      Provider.of<SplashProvider>(context, listen: false);
                  double deliveryCharge = 0.0;

                  if (_isFreeDelivery) {
                    deliveryCharge = 0.0;
                  } else {
                    if (splashProvider.deliveryInfoModelList != null &&
                        splashProvider.deliveryInfoModelList!.isNotEmpty &&
                        orderProvider.branchIndex <
                            splashProvider.deliveryInfoModelList!.length) {
                      final setup = splashProvider
                          .deliveryInfoModelList![orderProvider.branchIndex]
                          .deliveryChargeSetup;
                      if (setup?.deliveryChargeType == 'fixed') {
                        if (orderProvider.orderType == 'self_pickup' ||
                            orderProvider.orderType == 'convenient_delivery') {
                          deliveryCharge =
                              setup?.convenientDeliveryCharge?.toDouble() ?? 0.0;
                        } else if (orderProvider.orderType == 'fast_delivery' ||
                            orderProvider.orderType == 'delivery') {
                          deliveryCharge =
                              setup?.fastDeliveryCharge?.toDouble() ??
                                  (setup?.fixedDeliveryCharge?.toDouble() ??
                                      (configModel.deliveryCharge ?? 0.0));
                        } else {
                          deliveryCharge =
                              setup?.fixedDeliveryCharge?.toDouble() ??
                                  (configModel.deliveryCharge ?? 0.0);
                        }
                      } else {
                        deliveryCharge =
                            setup?.minimumDeliveryCharge?.toDouble() ??
                                (configModel.deliveryCharge ?? 0.0);
                      }
                    } else {
                      deliveryCharge = configModel.deliveryCharge ?? 0.0;
                    }
                  }

                  return Column(
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      PriceItemWidget(
                        title: getTranslated('delivery_fee', context),
                        subTitle: deliveryCharge <= 0
                            ? getTranslated('free', context)
                            : '+ ${PriceConverterHelper.convertPrice(context, deliveryCharge)}',
                      ),
                      Divider(
                        height: 30,
                        thickness: 1,
                        color: Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.1),
                      ),
                      PriceItemWidget(
                        title: getTranslated('total_amount', context),
                        subTitle: PriceConverterHelper.convertPrice(
                          context,
                          _total + deliveryCharge,
                        ),
                        style: poppinsBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
