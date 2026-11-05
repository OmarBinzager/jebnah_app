import 'package:flutter/material.dart';
import '../common/models/delivery_info_model.dart';
import '../features/address/domain/models/address_model.dart';
import '../common/models/config_model.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/checkout/enums/weight_charge_conditions.dart';
import '../features/checkout/enums/weight_charge_type.dart';
import '../features/order/domain/models/offline_payment_model.dart';
import '../features/order/enums/delivery_charge_type.dart';
import '../features/profile/domain/models/userinfo_model.dart';
import '../localization/language_constraints.dart';
import '../main.dart';
import '../features/address/providers/location_provider.dart';
import '../features/order/providers/order_provider.dart';
import '../features/splash/providers/splash_provider.dart';
import '../utill/images.dart';
import '../common/widgets/custom_loader_widget.dart';
import '../helper/custom_snackbar_helper.dart';
import '../features/checkout/widgets/delivery_fee_dialog_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckOutHelper {
  static List<PaymentMethod> getActivePaymentList({
    required ConfigModel configModel,
  }) {
    List<PaymentMethod> paymentMethodList = [];

    if (configModel.cashOnDelivery!) {
      paymentMethodList.add(
        PaymentMethod(
          getWay: 'cash_on_delivery',
          getWayImage: Images.cashOnDelivery,
        ),
      );
    }

    if (configModel.offlinePayment!) {
      paymentMethodList.add(
        PaymentMethod(
          getWay: 'offline_payment',
          getWayImage: Images.walletPayment,
        ),
      );
    }

    if (configModel.walletStatus!) {
      paymentMethodList.add(
        PaymentMethod(
          getWay: 'wallet_payment',
          getWayImage: Images.walletPayment,
        ),
      );
    }

    paymentMethodList.addAll(configModel.activePaymentMethodList ?? []);

    return paymentMethodList;
  }

  static double getDeliveryCharge({
    required double orderAmount,
    required double distance,
    required double discount,
    required String? freeDeliveryType,
    required ConfigModel configModel,
  }) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );

    double deliveryCharge = 0;

    if (freeDeliveryType == 'free_delivery') {
      deliveryCharge = 0;
    } else {
      if (getDeliveryChargeType() == DeliveryChargeType.fixed.name) {
        final setup = splashProvider
            .deliveryInfoModelList?[orderProvider.branchIndex]
            .deliveryChargeSetup;
        if (orderProvider.orderType == 'self_pickup' ||
            orderProvider.orderType == 'convenient_delivery') {
          deliveryCharge = setup?.convenientDeliveryCharge?.toDouble() ?? 0.0;
        } else if (orderProvider.orderType == 'fast_delivery' ||
            orderProvider.orderType == 'delivery') {
          deliveryCharge = setup?.fastDeliveryCharge?.toDouble() ??
              (setup?.fixedDeliveryCharge?.toDouble() ?? 0.0);
        } else {
          deliveryCharge = setup?.fixedDeliveryCharge?.toDouble() ?? 0.0;
        }
      } else if (getDeliveryChargeType() == DeliveryChargeType.distance.name) {
        final setup = splashProvider
            .deliveryInfoModelList?[orderProvider.branchIndex]
            .deliveryChargeSetup;

        double computedDistanceCharge = 0.0;
        if (distance != -1 && distance > 0) {
          if (getMinimumDistanceForFreeDelivery() > 0 &&
              distance < getMinimumDistanceForFreeDelivery()) {
            computedDistanceCharge = 0;
          } else {
            computedDistanceCharge = distance * getDeliveryChargePerKm();
            if (computedDistanceCharge <
                getMinimumDeliveryChargeForDistanceWise()) {
              computedDistanceCharge =
                  getMinimumDeliveryChargeForDistanceWise();
            }
          }
        } else {
          computedDistanceCharge = getMinimumDeliveryChargeForDistanceWise();
        }

        if (orderProvider.orderType == 'self_pickup' ||
            orderProvider.orderType == 'convenient_delivery') {
          if (setup?.convenientDeliveryCharge != null &&
              setup!.convenientDeliveryCharge! > 0) {
            deliveryCharge = setup.convenientDeliveryCharge!.toDouble();
          } else {
            deliveryCharge = computedDistanceCharge;
          }
        } else {
          deliveryCharge = computedDistanceCharge;
        }
      } else if (getDeliveryChargeType() == DeliveryChargeType.area.name) {
        deliveryCharge = getAreaWiseDeliveryCharge();
      }
    }
    return deliveryCharge;
  }

  static double calculateDistance({
    required ConfigModel configModel,
    required OrderProvider orderProvider,
    required LocationProvider locationProvider,
  }) {
    if (orderProvider.distance > 0) {
      return orderProvider.distance;
    }

    try {
      if (configModel.branches != null &&
          configModel.branches!.isNotEmpty &&
          orderProvider.branchIndex < configModel.branches!.length) {
        final branch = configModel.branches![orderProvider.branchIndex];
        final branchLat = double.tryParse(branch.latitude ?? '') ?? 0.0;
        final branchLng = double.tryParse(branch.longitude ?? '') ?? 0.0;

        double addressLat = 0.0;
        double addressLng = 0.0;

        if (locationProvider.addressList != null &&
            locationProvider.addressList!.isNotEmpty) {
          final address = (orderProvider.addressIndex >= 0 &&
                  orderProvider.addressIndex < locationProvider.addressList!.length)
              ? locationProvider.addressList![orderProvider.addressIndex]
              : locationProvider.addressList!.first;
          addressLat = double.tryParse(address.latitude ?? '') ?? 0.0;
          addressLng = double.tryParse(address.longitude ?? '') ?? 0.0;
        } else {
          addressLat = locationProvider.pickPosition.latitude;
          addressLng = locationProvider.pickPosition.longitude;
        }

        if (branchLat != 0.0 &&
            branchLng != 0.0 &&
            addressLat != 0.0 &&
            addressLng != 0.0) {
          double dist = Geolocator.distanceBetween(
                branchLat,
                branchLng,
                addressLat,
                addressLng,
              ) /
              1000.0;
          orderProvider.setDistance(dist, notify: false);
          return dist;
        }
      }
    } catch (_) {}

    return -1.0;
  }

  static bool isBranchAvailable({
    required List<Branches> branches,
    required Branches selectedBranch,
    required AddressModel selectedAddress,
  }) {
    bool isAvailable =
        branches.length == 1 &&
        (branches[0].latitude == null || branches[0].latitude!.isEmpty);

    if (!isAvailable) {
      double distance =
          Geolocator.distanceBetween(
            double.parse(selectedBranch.latitude!),
            double.parse(selectedBranch.longitude!),
            double.parse(selectedAddress.latitude!),
            double.parse(selectedAddress.longitude!),
          ) /
          1000;

      isAvailable = distance < selectedBranch.coverage!;
    }

    return isAvailable;
  }

  static AddressModel? getDeliveryAddress({
    required List<AddressModel?>? addressList,
    required AddressModel? selectedAddress,
    required AddressModel? lastOrderAddress,
  }) {
    AddressModel? deliveryAddress;
    if (selectedAddress != null) {
      deliveryAddress = selectedAddress;
    } else if (lastOrderAddress != null) {
      deliveryAddress = lastOrderAddress;
    } else if (addressList != null && addressList.isNotEmpty) {
      deliveryAddress = addressList.first;
    }

    return deliveryAddress;
  }

  static bool isKmWiseCharge({required ConfigModel? configModel}) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    return splashProvider
            .deliveryInfoModelList?[orderProvider.branchIndex]
            .deliveryChargeSetup
            ?.deliveryChargeType ==
        DeliveryChargeType.distance.name;
  }

  static bool isFreeDeliveryCharge({required String? type}) =>
      type == 'free_delivery';

  static bool isSelfPickup({required String? orderType}) =>
      orderType == 'self_pickup';

  static Future<void> selectDeliveryAddress({
    required bool isAvailable,
    required int index,
    required ConfigModel configModel,
    required LocationProvider locationProvider,
    required OrderProvider orderProvider,
    required bool fromAddressList,
  }) async {
    if (isAvailable) {
      locationProvider.updateAddressIndex(index, fromAddressList);
      orderProvider.setAddressIndex(index, notify: true);

      if (CheckOutHelper.isKmWiseCharge(configModel: configModel)) {
        double branchLat = double.tryParse(configModel.branches![orderProvider.branchIndex].latitude ?? '') ?? 0.0;
        double branchLng = double.tryParse(configModel.branches![orderProvider.branchIndex].longitude ?? '') ?? 0.0;
        double addressLat = double.tryParse(locationProvider.addressList![index].latitude ?? '') ?? 0.0;
        double addressLng = double.tryParse(locationProvider.addressList![index].longitude ?? '') ?? 0.0;

        if (branchLat != 0.0 && branchLng != 0.0 && addressLat != 0.0 && addressLng != 0.0) {
          double directDist = Geolocator.distanceBetween(branchLat, branchLng, addressLat, addressLng) / 1000.0;
          orderProvider.setDistance(directDist, notify: false);
        }

        bool isSuccess = false;
        if (fromAddressList) {
          showDialog(
            context: Get.context!,
            builder: (context) => Center(
              child: Container(
                height: 100,
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomLoaderWidget(color: Theme.of(context).primaryColor),
              ),
            ),
            barrierDismissible: false,
          );

          if (branchLat != 0.0 && addressLat != 0.0) {
            isSuccess = await orderProvider.getDistanceInMeter(
              LatLng(branchLat, branchLng),
              LatLng(addressLat, addressLng),
            );
          }

          Navigator.pop(Get.context!);
        } else {
          if (branchLat != 0.0 && addressLat != 0.0) {
            isSuccess = await orderProvider.getDistanceInMeter(
              LatLng(branchLat, branchLng),
              LatLng(addressLat, addressLng),
            );
          }
        }

        if (fromAddressList) {
          await showDialog(
            context: Get.context!,
            builder: (context) => DeliveryFeeDialogWidget(
              freeDelivery:
                  orderProvider.getCheckOutData?.freeDeliveryType ==
                  'free_delivery',
              amount: orderProvider.getCheckOutData?.amount ?? 0,
              distance: orderProvider.distance,
              callBack: (deliveryCharge) {
                orderProvider.getCheckOutData?.copyWith(
                  deliveryCharge: deliveryCharge,
                );
              },
            ),
          );
        } else {
          orderProvider.getCheckOutData?.copyWith(
            deliveryCharge: CheckOutHelper.getDeliveryCharge(
              freeDeliveryType: orderProvider.getCheckOutData?.freeDeliveryType,
              orderAmount: orderProvider.getCheckOutData?.amount ?? 0,
              distance: orderProvider.distance,
              discount: orderProvider.getCheckOutData?.placeOrderDiscount ?? 0,
              configModel: configModel,
            ),
          );

          orderProvider.setDeliveryCharge(
            orderProvider.getCheckOutData?.deliveryCharge,
          );
        }

        if (!isSuccess) {
          showCustomSnackBarHelper(
            getTranslated('failed_to_fetch_distance', Get.context!),
          );
        }
      }
    } else {
      showCustomSnackBarHelper(
        getTranslated('out_of_coverage_for_this_branch', Get.context!),
      );
    }
  }

  static bool isWalletPayment({
    required ConfigModel configModel,
    required bool isLogin,
    required double? partialAmount,
    required bool isPartialPayment,
  }) {
    return configModel.walletStatus! &&
        isLogin &&
        (partialAmount == null) &&
        !isPartialPayment;
  }

  static bool isPartialPayment({
    required ConfigModel configModel,
    required bool isLogin,
    required UserInfoModel? userInfoModel,
  }) {
    return isLogin &&
        configModel.isPartialPayment! &&
        configModel.walletStatus! &&
        (userInfoModel != null && userInfoModel.walletBalance! > 0);
  }

  static bool isPartialPaymentSelected({
    required int? paymentMethodIndex,
    required PaymentMethod? selectedPaymentMethod,
  }) {
    return (paymentMethodIndex == 1 && selectedPaymentMethod != null);
  }

  static List<Map<String, dynamic>> getOfflineMethodJson(
    List<MethodField>? methodList,
  ) {
    List<Map<String, dynamic>> mapList = [];
    List<String?> keyList = [];
    List<String?> valueList = [];

    for (MethodField methodField in (methodList ?? [])) {
      keyList.add(methodField.fieldName);
      valueList.add(methodField.fieldData);
    }

    for (int i = 0; i < keyList.length; i++) {
      mapList.add({'${keyList[i]}': '${valueList[i]}'});
    }

    return mapList;
  }

  static Future<void> selectDeliveryAddressAuto({
    AddressModel? lastAddress,
    required bool isLoggedIn,
    required String? orderType,
  }) async {
    final LocationProvider locationProvider = Provider.of<LocationProvider>(
      Get.context!,
      listen: false,
    );
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      Get.context!,
      listen: false,
    );

    if (authProvider.isLoggedIn()) {
      lastAddress ??= await locationProvider.getLastOrderedAddress();
    }

    AddressModel? deliveryAddress = CheckOutHelper.getDeliveryAddress(
      addressList: locationProvider.addressList,
      selectedAddress: orderProvider.addressIndex == -1
          ? null
          : locationProvider.addressList?[orderProvider.addressIndex],
      lastOrderAddress: lastAddress,
    );

    if (isLoggedIn &&
        deliveryAddress != null &&
        (orderType == 'delivery' || orderType == 'self_pickup' || orderType == 'convenient_delivery') &&
        locationProvider.getAddressIndex(deliveryAddress) != null) {
      if (((deliveryAddress.longitude != null &&
                  deliveryAddress.longitude!.isNotEmpty) &&
              (deliveryAddress.latitude != null &&
                  deliveryAddress.latitude!.isNotEmpty) &&
              getDeliveryChargeType() == DeliveryChargeType.distance.name) ||
          (!(getDeliveryChargeType() == DeliveryChargeType.distance.name))) {
        await CheckOutHelper.selectDeliveryAddress(
          isAvailable: true,
          index: locationProvider.getAddressIndex(deliveryAddress)!,
          configModel: splashProvider.configModel!,
          locationProvider: locationProvider,
          orderProvider: orderProvider,
          fromAddressList: false,
        );
      }
    }
  }

  static String getDeliveryChargeType() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );

    return splashProvider
            .deliveryInfoModelList?[orderProvider.branchIndex]
            .deliveryChargeSetup
            ?.deliveryChargeType ??
        '';
  }

  static double getDeliveryChargePerKm() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );

    return splashProvider
            .deliveryInfoModelList?[orderProvider.branchIndex]
            .deliveryChargeSetup
            ?.deliveryChargePerKilometer
            ?.toDouble() ??
        0.0;
  }

  static double getMinimumDeliveryChargeForDistanceWise() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );

    return splashProvider
            .deliveryInfoModelList?[orderProvider.branchIndex]
            .deliveryChargeSetup
            ?.minimumDeliveryCharge
            ?.toDouble() ??
        0.0;
  }

  static double getMinimumDistanceForFreeDelivery() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );

    return splashProvider
            .deliveryInfoModelList?[orderProvider.branchIndex]
            .deliveryChargeSetup
            ?.minimumDistanceForFreeDelivery
            ?.toDouble() ??
        0.0;
  }

  static double getAreaWiseDeliveryCharge() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      Get.context!,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      Get.context!,
      listen: false,
    );
    if (orderProvider.selectedAreaID == null) {
      return 0.0;
    } else {
      return splashProvider
              .deliveryInfoModelList?[orderProvider.branchIndex]
              .deliveryChargeByArea
              ?.firstWhere((area) => area.id == orderProvider.selectedAreaID)
              .deliveryCharge
              ?.toDouble() ??
          0.0;
    }
  }

  static bool isGuestCheckout({BuildContext? context}) {
    final ctx = context ?? Get.context;
    if (ctx == null) return false;
    try {
      final SplashProvider splashProvider = Provider.of<SplashProvider>(
        ctx,
        listen: false,
      );
      final AuthProvider authProvider = Provider.of<AuthProvider>(
        ctx,
        listen: false,
      );

      return (splashProvider.configModel?.isGuestCheckout ?? false) &&
          authProvider.getGuestId() != null;
    } catch (_) {
      return false;
    }
  }

  static double weightChargeCalculation(
    double? weight,
    DeliveryInfoModel? deliveryInfoModel,
  ) {
    double weightCharge = 0.0;

    try {
      if (deliveryInfoModel?.deliveryWeightSettingsStatus ?? false) {
        if (deliveryInfoModel?.deliveryWeightChargeType ==
                WeightChargeType.unit.name &&
            weight != null &&
            deliveryInfoModel?.deliveryCountChargeFrom != null) {
          final countFrom = double.tryParse(deliveryInfoModel!.deliveryCountChargeFrom!) ?? 0.0;
          final addCharge = double.tryParse(deliveryInfoModel.deliveryAdditionalChargePerUnit ?? '0') ?? 0.0;

          if (deliveryInfoModel.deliveryCountChargeFromOperation ==
                  WeightChargeConditions.greater_or_equal.name &&
              weight >= countFrom) {
            if (weight == countFrom) {
              weightCharge = addCharge;
            } else if (weight > countFrom) {
              double diff = weight - countFrom;
              if (diff > 0) {
                weightCharge = (diff * addCharge) + addCharge;
              }
            }
          } else if (deliveryInfoModel.deliveryCountChargeFromOperation ==
                  WeightChargeConditions.greater.name &&
              weight > countFrom) {
            double diff = weight - countFrom;
            if (diff > 0) {
              weightCharge = diff * addCharge;
            }
          }
        } else if (deliveryInfoModel?.deliveryWeightChargeType ==
            WeightChargeType.range.name) {
          List<Map<String, dynamic>> weightRanges = (deliveryInfoModel?.deliveryWeightRange ?? [])
              .map((weightRange) => weightRange.toJson())
              .toList();

          for (var range in weightRanges) {
            double minWeight = double.tryParse('${range['min_weight']}') ?? 0.0;
            double maxWeight = double.tryParse('${range['max_weight']}') ?? 0.0;
            String minOperation = range['min_operation'] ?? '';
            String maxOperation = range['max_operation'] ?? '';
            double deliveryCharge = double.tryParse('${range['delivery_charge']}') ?? 0.0;

            bool minConditionMet = false;
            bool maxConditionMet = false;

            if (minOperation == WeightChargeConditions.greater.name &&
                weight != null && weight > minWeight) {
              minConditionMet = true;
            } else if (minOperation ==
                    WeightChargeConditions.greater_or_equal.name &&
                weight != null && weight >= minWeight) {
              minConditionMet = true;
            }

            if (maxOperation == WeightChargeConditions.less.name &&
                weight != null && weight < maxWeight) {
              maxConditionMet = true;
            } else if (maxOperation ==
                    WeightChargeConditions.less_or_equal.name &&
                weight != null && weight <= maxWeight) {
              maxConditionMet = true;
            }
            if (minConditionMet && maxConditionMet) {
              weightCharge = deliveryCharge;
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('weightChargeCalculation error: $e');
      weightCharge = 0.0;
    }

    return weightCharge;
  }
}
