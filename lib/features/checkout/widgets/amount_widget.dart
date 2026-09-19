import 'package:flutter/material.dart';
import '../../../common/widgets/custom_directionality_widget.dart';
import '../../../features/checkout/domain/models/check_out_model.dart';
import '../../../features/checkout/widgets/total_amount_widget.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../helper/checkout_helper.dart';
import '../../../helper/price_converter_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class AmountWidget extends StatelessWidget {
  final double total;
  final double? weight;
  const AmountWidget({super.key, required this.total, this.weight});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        CheckOutModel? checkOutData = Provider.of<OrderProvider>(
          context,
          listen: false,
        ).getCheckOutData;
        bool isFreeDelivery = CheckOutHelper.isFreeDeliveryCharge(
          type: checkOutData?.orderType,
        );
        bool showPayment = orderProvider.selectedPaymentMethod != null;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
          ),
          child: Column(
            children: [
              const SizedBox(height: Dimensions.paddingSizeLarge),
              if (ResponsiveHelper.isDesktop(context))
                TotalAmountWidget(
                  amount: checkOutData?.amount ?? 0,
                  freeDelivery: isFreeDelivery,
                  weight: weight,
                  deliveryCharge: checkOutData?.deliveryCharge ?? 0,
                ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Divider(
                height: 2,
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              if (orderProvider.partialAmount != null)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated('wallet_payment', context),
                          style: poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),

                        CustomDirectionalityWidget(
                          child: Text(
                            PriceConverterHelper.convertPrice(
                              context,
                              orderProvider.partialAmount ?? 0,
                            ),
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          showPayment &&
                                  orderProvider.selectedPaymentMethod?.type !=
                                      'cash_on_delivery'
                              ? getTranslated(
                                  orderProvider
                                      .selectedPaymentMethod
                                      ?.getWayTitle,
                                  context,
                                )
                              : '${getTranslated('due_amount', context)} ${orderProvider.selectedPaymentMethod?.type == 'cash_on_delivery' ? '(${getTranslated(orderProvider.selectedPaymentMethod?.type, context)})' : ''}',
                          style: poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),

                        CustomDirectionalityWidget(
                          child: Text(
                            PriceConverterHelper.convertPrice(
                              context,
                              total +
                                  (weight ?? 0) -
                                  (orderProvider.partialAmount ?? 0),
                            ),
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),

              if (ResponsiveHelper.isDesktop(context)) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated('total_amount', context),
                      style: poppinsSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),

                    CustomDirectionalityWidget(
                      child: Text(
                        PriceConverterHelper.convertPrice(
                          context,
                          total + (weight ?? 0),
                        ),
                        style: poppinsSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
