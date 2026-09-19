import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../features/address/domain/models/address_model.dart';
import '../../../common/models/config_model.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/address/providers/location_provider.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../main.dart';
import '../../../utill/dimensions.dart';
import '../../../common/widgets/custom_button_widget.dart';
import '../../../helper/custom_snackbar_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class AddAddressWidget extends StatelessWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final TextEditingController streetNumberController;
  final TextEditingController houseNumberController;
  final TextEditingController floorNumberController;
  final TextEditingController cityController;
  final TextEditingController districtController;
  final TextEditingController streetNameController;
  final AddressModel? address;
  final String countryCode;

  const AddAddressWidget({
    super.key,
    required this.isEnableUpdate,
    required this.fromCheckout,
    required this.contactPersonNumberController,
    required this.contactPersonNameController,
    required this.address,
    required this.streetNumberController,
    required this.floorNumberController,
    required this.houseNumberController,
    required this.countryCode,
    required this.cityController,
    required this.districtController,
    required this.streetNameController,
  });

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    return Column(
      children: [
        locationProvider.addressStatusMessage != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  locationProvider.addressStatusMessage!.isNotEmpty
                      ? const CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 5,
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locationProvider.addressStatusMessage ?? "",
                      style: Theme.of(context).textTheme.displayMedium!
                          .copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.green,
                            height: 1,
                          ),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  locationProvider.errorMessage!.isNotEmpty
                      ? const CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 5,
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locationProvider.errorMessage ?? "",
                      style: Theme.of(context).textTheme.displayMedium!
                          .copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.red,
                            height: 1,
                          ),
                    ),
                  ),
                ],
              ),
        SizedBox(
          height: ResponsiveHelper.isDesktop(context)
              ? 0
              : Dimensions.paddingSizeSmall,
        ),

        Container(
          height: 50.0,
          width: Dimensions.webScreenWidth,
          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: !locationProvider.isLoading
              ? CustomButtonWidget(
                  buttonText: isEnableUpdate
                      ? getTranslated('update_address', context)
                      : getTranslated('save_location', context),
                  onPressed: locationProvider.loading
                      ? null
                      : () {
                          final SplashProvider splashProvider =
                              Provider.of<SplashProvider>(
                                context,
                                listen: false,
                              );
                          List<Branches> branches =
                              splashProvider.configModel!.branches!;
                          bool isAvailable =
                              branches.length == 1 &&
                              (branches[0].latitude == null ||
                                  branches[0].latitude!.isEmpty);

                          if (!isAvailable) {
                            if (splashProvider.configModel?.googleMapStatus ??
                                false) {
                              for (Branches branch in branches) {
                                double distance =
                                    Geolocator.distanceBetween(
                                      double.parse(branch.latitude!),
                                      double.parse(branch.longitude!),
                                      locationProvider.position.latitude,
                                      locationProvider.position.longitude,
                                    ) /
                                    1000;
                                if (distance < branch.coverage!) {
                                  isAvailable = true;
                                  break;
                                }
                              }
                            } else {
                              isAvailable = true;
                            }
                          }
                          if (!isAvailable) {
                            showCustomSnackBarHelper(
                              getTranslated(
                                'service_is_not_available',
                                context,
                              ),
                            );
                          } else {
                            // بناء العنوان الكامل من الحقول المختلفة
                            String fullAddress = _buildFullAddress(
                              locationProvider,
                            );

                            AddressModel addressModel = AddressModel(
                              addressType:
                                  locationProvider
                                      .getAllAddressType[locationProvider
                                      .selectAddressIndex],
                              contactPersonName: contactPersonNameController
                                  .text
                                  .trim(),
                              contactPersonNumber:
                                  contactPersonNumberController.text
                                      .trim()
                                      .isEmpty
                                  ? ''
                                  : '${CountryCode.fromCountryCode(countryCode).dialCode}${contactPersonNumberController.text.trim()}',
                              address: fullAddress,
                              latitude:
                                  (splashProvider
                                          .configModel
                                          ?.googleMapStatus ??
                                      false)
                                  ? locationProvider.position.latitude
                                        .toString()
                                  : null,
                              longitude:
                                  (splashProvider
                                          .configModel
                                          ?.googleMapStatus ??
                                      false)
                                  ? locationProvider.position.longitude
                                        .toString()
                                  : null,
                              floorNumber: floorNumberController.text.trim(),
                              houseNumber: houseNumberController.text.trim(),
                              streetNumber: streetNumberController.text.trim(),
                              city: cityController.text.trim(),
                              district: districtController.text.trim(),
                              streetName: streetNameController.text.trim(),
                            );

                            if (isEnableUpdate) {
                              addressModel.id = address!.id;
                              addressModel.userId = address!.userId;
                              addressModel.method = 'put';
                              locationProvider
                                  .updateAddress(
                                    context,
                                    addressModel: addressModel,
                                    addressId: addressModel.id,
                                  )
                                  .then((value) {
                                    if (value.isSuccess) {
                                      showCustomSnackBarHelper(
                                        getTranslated(
                                          'address_updated_successfully',
                                          context,
                                        ),
                                        isError: false,
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      showCustomSnackBarHelper(value.message!);
                                    }
                                  });
                            } else {
                              locationProvider
                                  .addAddress(addressModel, context)
                                  .then((value) {
                                    if (value.isSuccess) {
                                      if (fromCheckout) {
                                        Provider.of<LocationProvider>(
                                          Get.context!,
                                          listen: false,
                                        ).initAddressList();
                                        Provider.of<OrderProvider>(
                                          Get.context!,
                                          listen: false,
                                        ).setAddressIndex(-1);
                                      } else {
                                        showCustomSnackBarHelper(
                                          value.message ?? '',
                                          isError: false,
                                        );
                                      }
                                      if (Navigator.canPop(Get.context!)) {
                                        Navigator.pop(Get.context!);
                                      } else {
                                        Provider.of<SplashProvider>(
                                          Get.context!,
                                        ).setPageIndex(0);
                                        RouteHelper.getMainRoute(
                                          action: RouteAction
                                              .pushNamedAndRemoveUntil,
                                        );
                                      }
                                    } else {
                                      showCustomSnackBarHelper(value.message!);
                                    }
                                  });
                            }
                          }
                        },
                )
              : Center(
                  child: CustomLoaderWidget(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
        ),
      ],
    );
  }

  // دالة لبناء العنوان الكامل من الحقول المختلفة
  String _buildFullAddress(LocationProvider locationProvider) {
    String fullAddress = locationProvider.address ?? '';

    // إضافة المدينة
    if (cityController.text.trim().isNotEmpty) {
      fullAddress = fullAddress.isEmpty
          ? cityController.text.trim()
          : '$fullAddress, ${cityController.text.trim()}';
    }

    // إضافة المنطقة
    if (districtController.text.trim().isNotEmpty) {
      fullAddress = fullAddress.isEmpty
          ? districtController.text.trim()
          : '$fullAddress, ${districtController.text.trim()}';
    }

    // إضافة اسم الشارع
    if (streetNameController.text.trim().isNotEmpty) {
      fullAddress = fullAddress.isEmpty
          ? streetNameController.text.trim()
          : '$fullAddress, ${streetNameController.text.trim()}';
    }

    // إضافة رقم الشارع
    if (streetNumberController.text.trim().isNotEmpty) {
      fullAddress = fullAddress.isEmpty
          ? 'Street ${streetNumberController.text.trim()}'
          : '$fullAddress, Street ${streetNumberController.text.trim()}';
    }

    // إضافة رقم المنزل
    if (houseNumberController.text.trim().isNotEmpty) {
      fullAddress = fullAddress.isEmpty
          ? 'House ${houseNumberController.text.trim()}'
          : '$fullAddress, House ${houseNumberController.text.trim()}';
    }

    // إضافة رقم الطابق
    if (floorNumberController.text.trim().isNotEmpty) {
      fullAddress = fullAddress.isEmpty
          ? 'Floor ${floorNumberController.text.trim()}'
          : '$fullAddress, Floor ${floorNumberController.text.trim()}';
    }

    return fullAddress;
  }
}
