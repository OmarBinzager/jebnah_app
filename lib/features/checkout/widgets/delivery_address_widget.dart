import 'package:flutter/material.dart';
import '../../../features/address/domain/models/address_model.dart';
import '../../../common/models/config_model.dart';
import '../../../features/order/enums/delivery_charge_type.dart';
import '../../../helper/checkout_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/address/providers/location_provider.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_shadow_widget.dart';
import '../../../features/checkout/widgets/add_address_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class DeliveryAddressWidget extends StatelessWidget {
  final bool selfPickup;

  const DeliveryAddressWidget({super.key, required this.selfPickup});

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel!;

    return !selfPickup
        ? CustomShadowWidget(
            margin: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Consumer<LocationProvider>(
              builder: (context, locationProvider, _) => Consumer<OrderProvider>(
                builder: (context, orderProvider, _) {
                  bool isAvailable = false;

                  AddressModel? deliveryAddress =
                      CheckOutHelper.getDeliveryAddress(
                        addressList: locationProvider.addressList,
                        selectedAddress: orderProvider.addressIndex == -1
                            ? null
                            : locationProvider.addressList?[orderProvider
                                  .addressIndex],
                        lastOrderAddress: null,
                      );
                  if (deliveryAddress != null &&
                      (configModel.googleMapStatus ?? false) &&
                      CheckOutHelper.getDeliveryChargeType() ==
                          DeliveryChargeType.distance.name &&
                      ((deliveryAddress.latitude != null &&
                              deliveryAddress.latitude!.isNotEmpty) &&
                          (deliveryAddress.longitude != null &&
                              deliveryAddress.longitude!.isNotEmpty))) {
                    isAvailable = CheckOutHelper.isBranchAvailable(
                      branches: configModel.branches ?? [],
                      selectedBranch:
                          configModel.branches![orderProvider.branchIndex],
                      selectedAddress: deliveryAddress,
                    );

                    if (!isAvailable) {
                      deliveryAddress = null;
                    }
                  }

                  return locationProvider.addressList == null
                      ? const _DeliverySectionShimmer()
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${getTranslated('delivery_to', context)} -',
                                    style: poppinsMedium.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                    ),
                                  ),
                                  const Expanded(child: SizedBox()),

                                  TextButton(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) =>
                                          const AddAddressDialogWidget(),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '+',
                                          style: poppinsBold.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall,
                                        ),

                                        Text(
                                          getTranslated(
                                            deliveryAddress == null ||
                                                    orderProvider
                                                            .addressIndex ==
                                                        -1
                                                ? 'add'
                                                : 'change',
                                            context,
                                          ),
                                          style: poppinsBold.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeDefault,
                              ),

                              deliveryAddress == null ||
                                      orderProvider.addressIndex == -1
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: Dimensions.paddingSizeDefault,
                                      ),
                                      child: Center(
                                        child: Text(
                                          getTranslated(
                                            'no_address_available',
                                            context,
                                          ),
                                          style: poppinsRegular,
                                        ),
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.5),
                                            ),
                                            const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall,
                                            ),

                                            Flexible(
                                              child: Text(
                                                deliveryAddress
                                                        .contactPersonName ??
                                                    '',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: Dimensions.paddingSizeSmall,
                                        ),

                                        Row(
                                          children: [
                                            Icon(
                                              Icons.call,
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.5),
                                            ),
                                            const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall,
                                            ),

                                            Text(
                                              deliveryAddress
                                                      .contactPersonNumber ??
                                                  '',
                                            ),
                                          ],
                                        ),

                                        const Divider(
                                          height: Dimensions.paddingSizeDefault,
                                        ),

                                        Text(
                                          deliveryAddress.address ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(
                                          height: Dimensions.paddingSizeSmall,
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            if (deliveryAddress.houseNumber !=
                                                null)
                                              Text(
                                                '${getTranslated('house', context)} - ${deliveryAddress.houseNumber}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall,
                                            ),

                                            if (deliveryAddress.floorNumber !=
                                                null)
                                              Text(
                                                '${getTranslated('floor', context)} - ${deliveryAddress.floorNumber}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: Dimensions.paddingSizeDefault,
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        );
                },
              ),
            ),
          )
        : const SizedBox();
  }
}

class _DeliverySectionShimmer extends StatelessWidget {
  const _DeliverySectionShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Column(
              children: [
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 14,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      height: 14,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),

                const Divider(height: Dimensions.paddingSizeDefault),

                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: Dimensions.paddingSizeLarge,
                          width: Dimensions.paddingSizeLarge,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeLarge),

                        Container(
                          height: 14,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: Dimensions.paddingSizeLarge,
                          width: Dimensions.paddingSizeLarge,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeLarge),

                        Container(
                          height: 14,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
