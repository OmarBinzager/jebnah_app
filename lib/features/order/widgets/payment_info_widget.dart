import 'package:flutter/material.dart';
import '../../../common/widgets/custom_single_child_list_widget.dart';
import '../../../common/widgets/key_value_item_widget.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/order/domain/models/order_model.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class PaymentInfoWidget extends StatelessWidget {
  final DeliveryAddress? deliveryAddress;
  const PaymentInfoWidget({super.key, required this.deliveryAddress});

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      context,
      listen: false,
    );
    final bool isLoggedIn = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getTranslated('payment_verification', context),
            style: poppinsMedium,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated('customer_info', context),
                style: poppinsMedium,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              KeyValueItemWidget(
                item: getTranslated('name', context),
                value: isLoggedIn
                    ? '${profileProvider.userInfoModel?.fName ?? ''} ${profileProvider.userInfoModel?.lName ?? ''}'
                    : deliveryAddress?.contactPersonName ?? '',
              ),

              KeyValueItemWidget(
                item: getTranslated('phone_number', context),
                value: isLoggedIn
                    ? profileProvider.userInfoModel?.phone ?? ''
                    : deliveryAddress?.contactPersonNumber ?? '',
              ),
            ],
          ),
          Divider(color: Theme.of(context).dividerColor),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                getTranslated('payment_info', context),
                style: poppinsMedium,
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          KeyValueItemWidget(
            item: getTranslated('method_name', context),
            value:
                orderProvider
                    .trackModel
                    ?.offlinePaymentInformation
                    ?.paymentName ??
                '',
          ),

          CustomSingleChildListWidget(
            itemCount:
                orderProvider
                    .trackModel
                    ?.offlinePaymentInformation
                    ?.methodInformation
                    ?.length ??
                0,
            itemBuilder: (int index) => KeyValueItemWidget(
              item:
                  orderProvider
                      .trackModel
                      ?.offlinePaymentInformation
                      ?.methodInformation?[index]
                      .key ??
                  '',
              value:
                  orderProvider
                      .trackModel
                      ?.offlinePaymentInformation
                      ?.methodInformation?[index]
                      .value ??
                  '',
            ),
          ),
          KeyValueItemWidget(
            item: getTranslated('payment_note', context),
            value:
                orderProvider
                    .trackModel
                    ?.offlinePaymentInformation
                    ?.paymentNote ??
                '',
          ),
        ],
      ),
    );
  }
}
