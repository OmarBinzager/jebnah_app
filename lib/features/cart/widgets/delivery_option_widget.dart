import 'package:flutter/material.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class DeliveryOptionWidget extends StatelessWidget {
  final String value;
  final String? title;
  final String? subTitle;
  const DeliveryOptionWidget({
    super.key,
    required this.value,
    required this.title,
    this.subTitle,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: value,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: order.orderType == value
                                ? poppinsSemiBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  )
                                : poppinsRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                          ),
                          if (subTitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subTitle!,
                              style: poppinsMedium.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
