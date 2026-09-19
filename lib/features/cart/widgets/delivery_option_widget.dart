import 'package:flutter/material.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class DeliveryOptionWidget extends StatelessWidget {
  final String value;
  final String? title;
  const DeliveryOptionWidget({
    super.key,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).hintColor.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      child: Consumer<OrderProvider>(
        builder: (context, order, child) {
          return RadioGroup<String>(
            groupValue: order.orderType,
            onChanged: (value) {
              if (value != null) {
                order.setOrderType(value);
              }
            },
            child: InkWell(
              onTap: () => order.setOrderType(value),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(value: value),

                  Text(
                    title!,
                    style: order.orderType == value
                        ? poppinsSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          )
                        : poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
