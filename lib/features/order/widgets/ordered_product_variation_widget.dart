import 'package:flutter/material.dart';
import '../../../features/order/domain/models/order_details_model.dart';
import '../../../helper/order_helper.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';

class OrderedProductVariationWidget extends StatelessWidget {
  final OrderDetailsModel orderDetailsModel;
  const OrderedProductVariationWidget({
    super.key,
    required this.orderDetailsModel,
  });

  @override
  Widget build(BuildContext context) {
    return OrderHelper.getVariationValue(
              orderDetailsModel.formattedVariation,
            ).isNotEmpty &&
            OrderHelper.getVariationValue(
                  orderDetailsModel.formattedVariation,
                ) !=
                'null'
        ? Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Text(
                OrderHelper.getVariationValue(
                  orderDetailsModel.formattedVariation,
                ),
                style: poppinsRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}
