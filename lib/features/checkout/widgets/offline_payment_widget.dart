import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../common/models/cart_model.dart';
import '../../../common/models/place_order_model.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../common/providers/currency_provider.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../features/address/providers/location_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/checkout/domain/models/check_out_model.dart';
import '../../../features/coupon/providers/coupon_provider.dart';
import '../../../features/order/domain/models/offline_payment_model.dart';
import '../../../features/order/domain/models/order_model.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../helper/checkout_helper.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../../../helper/price_converter_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/app_localization.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../main.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_button_widget.dart';
import '../../../common/widgets/custom_text_field_widget.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class OfflinePaymentWidget extends StatefulWidget {
  final double totalAmount;
  final OfflinePaymentModel? selectedOfflineMethod;
  final OfflinePaymentInformation? orderOfflineData;
  final double? partialAmount;
  final String? orderId;
  final bool fromCheckout;
  final void Function({List<Map<String, String>>? selectedOfflineValue})?
  callBack;
  const OfflinePaymentWidget({
    super.key,
    required this.totalAmount,
    this.selectedOfflineMethod,
    this.callBack,
    this.partialAmount,
    this.orderId,
    this.orderOfflineData,
    this.fromCheckout = false,
  });

  @override
  State<OfflinePaymentWidget> createState() => _OfflinePaymentWidgetState();
}

class _OfflinePaymentWidgetState extends State<OfflinePaymentWidget> {
  AutoScrollController? scrollController;
  Map<String, String>? selectedValue;

  @override
  void initState() {
    scrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );

    if (widget.orderOfflineData != null) {
      OfflinePaymentModel? offlinePaymentModel =
          Provider.of<SplashProvider>(
            context,
            listen: false,
          ).offlinePaymentModelList?.firstWhere(
            (offline) =>
                offline?.methodName == widget.orderOfflineData?.paymentName,
          );
      Provider.of<OrderProvider>(context, listen: false).changePaymentMethod(
        offlinePaymentModel: offlinePaymentModel,
        isUpdate: false,
      );
    }

    int? index;

    if (widget.orderOfflineData != null) {
      OfflinePaymentModel? offlinePaymentModel =
          Provider.of<SplashProvider>(
            context,
            listen: false,
          ).offlinePaymentModelList?.firstWhere(
            (offline) =>
                offline?.methodName == widget.orderOfflineData?.paymentName,
          );
      index = Provider.of<SplashProvider>(
        context,
        listen: false,
      ).offlinePaymentModelList?.indexOf(offlinePaymentModel);
    } else {
      index = Provider.of<SplashProvider>(
        context,
        listen: false,
      ).offlinePaymentModelList?.indexOf(widget.selectedOfflineMethod);
    }

    if (index != null && index != -1) {
      scrollController?.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.middle,
      );
      scrollController?.highlight(index);
    }

    Provider.of<OrderProvider>(context, listen: false).changePaymentMethod(
      offlinePaymentModel: widget.selectedOfflineMethod,
      isUpdate: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      width: 550,
      margin: const EdgeInsets.only(top: kIsWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile()
            ? const BorderRadius.vertical(
                top: Radius.circular(Dimensions.radiusSizeLarge),
              )
            : BorderRadius.all(Radius.circular(Dimensions.radiusSizeDefault)),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      child: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          // return Text('data');
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Container(
                        height: 5,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSizeDefault,
                          ),
                          color: Theme.of(
                            context,
                          ).hintColor.withValues(alpha: 0.2),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Text(
                        getTranslated('offline_payment', context),
                        style: poppinsMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Image.asset(Images.offlinePayment, height: 100),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                        ),
                        child: Text(
                          getTranslated(
                            'pay_your_bill_using_the_info',
                            context,
                          ),
                          textAlign: TextAlign.center,
                          style: poppinsLight.copyWith(
                            fontSize: Dimensions.fontSizeSmall + 1,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      if (widget.orderId != null &&
                          widget.orderId!.isNotEmpty &&
                          widget.orderId != "null")
                        RichText(
                          text: TextSpan(
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: getTranslated('order', context),
                                style: poppinsRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ),
                              TextSpan(text: ' # ', style: poppinsRegular),
                              TextSpan(
                                text: widget.orderId,
                                style: poppinsMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          getTranslated('offline_payment', context),
                          style: poppinsMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),

                      Text(
                        PriceConverterHelper.convertPrice(
                          context,
                          widget.totalAmount,
                        ),
                        style: poppinsBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                        ),
                      ),

                      if (widget.partialAmount != null &&
                          ((widget.totalAmount - (widget.partialAmount ?? 0))) >
                              0)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeSmall,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.08),
                          ),
                          margin: EdgeInsets.only(
                            top: Dimensions.paddingSizeExtraSmall,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: poppinsRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: getTranslated('wallet', context),
                                      style: poppinsRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' : ',
                                      style: poppinsRegular,
                                    ),
                                    TextSpan(
                                      text: PriceConverterHelper.convertPrice(
                                        context,
                                        (widget.totalAmount -
                                            (widget.partialAmount ?? 0)),
                                      ),
                                      style: poppinsBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                height: 15,
                                width: 1,
                                color: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.5),
                                margin: EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: poppinsRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: getTranslated('offline', context),
                                      style: poppinsRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' : ',
                                      style: poppinsRegular,
                                    ),
                                    TextSpan(
                                      text: PriceConverterHelper.convertPrice(
                                        context,
                                        widget.partialAmount ?? 0,
                                      ),
                                      style: poppinsBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          child: IntrinsicHeight(
                            child: Row(
                              children: (splashProvider.offlinePaymentModelList ?? [])
                                  .map(
                                    (offline) => AutoScrollTag(
                                      controller: scrollController!,
                                      key: ValueKey(
                                        splashProvider.offlinePaymentModelList!
                                            .indexOf(offline),
                                      ),
                                      index: splashProvider
                                          .offlinePaymentModelList!
                                          .indexOf(offline),
                                      child: InkWell(
                                        onTap: () async {
                                          orderProvider.formKey.currentState
                                              ?.reset();
                                          orderProvider.changePaymentMethod(
                                            offlinePaymentModel: offline,
                                          );

                                          await scrollController!.scrollToIndex(
                                            splashProvider
                                                .offlinePaymentModelList!
                                                .indexOf(offline),
                                            preferPosition:
                                                AutoScrollPosition.middle,
                                          );
                                          await scrollController!.highlight(
                                            splashProvider
                                                .offlinePaymentModelList!
                                                .indexOf(offline),
                                          );
                                        },
                                        child: Container(
                                          width: (splashProvider.offlinePaymentModelList?.length ?? 0) <= 1
                                              ? (MediaQuery.sizeOf(context).width - 32)
                                              : ResponsiveHelper.isMobile()
                                                  ? (MediaQuery.sizeOf(context).width * 0.88).clamp(300.0, 480.0)
                                                  : 340,
                                          constraints: const BoxConstraints(
                                            minHeight: 140,
                                          ),
                                          padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeDefault,
                                          ),
                                          margin: const EdgeInsets.all(
                                            Dimensions.paddingSizeExtraSmall,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.1),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSizeDefault,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(
                                                      alpha:
                                                          offline?.id ==
                                                              orderProvider
                                                                  .selectedOfflineMethod
                                                                  ?.id
                                                          ? 0.2
                                                          : 0.05,
                                                    ),
                                                offset: const Offset(0, 4),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                      children: [
                                                        if (offline?.imageFullPath != null &&
                                                            offline!.imageFullPath!.isNotEmpty) ...[
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  Dimensions.radiusSizeSmall,
                                                                ),
                                                            child: CustomImageWidget(
                                                              image: offline.imageFullPath ?? '',
                                                              height: 32,
                                                              width: 32,
                                                              fit: BoxFit.contain,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: Dimensions.paddingSizeSmall,
                                                          ),
                                                        ],
                                                        Expanded(
                                                          child: Text(
                                                            offline?.methodName ?? '',
                                                            style: poppinsBold
                                                                .copyWith(
                                                                  fontSize: Dimensions
                                                                      .fontSizeDefault,
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).primaryColor,
                                                                ),
                                                            maxLines: 2,
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (offline?.id ==
                                                      orderProvider
                                                          .selectedOfflineMethod
                                                          ?.id) ...[
                                                    const SizedBox(
                                                      width: Dimensions.paddingSizeExtraSmall,
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusSizeSmall,
                                                            ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 3,
                                                            horizontal: 6,
                                                          ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            getTranslated(
                                                              'pay_on_this_account',
                                                              context,
                                                            ),
                                                            style: poppinsRegular.copyWith(
                                                              color: Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                              fontSize: Dimensions
                                                                  .fontSizeExtraSmall,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .check_circle_rounded,
                                                            color: Theme.of(
                                                              context,
                                                            ).primaryColor,
                                                            size: 14,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeDefault,
                                              ),

                                              if (offline?.methodFields != null)
                                                _BillInfoWidget(
                                                  methodList:
                                                      offline!.methodFields!,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      if (orderProvider.selectedOfflineMethod != null)
                        _TransferInstructionsWidget(
                          selectedMethod: orderProvider.selectedOfflineMethod,
                        ),

                      if (orderProvider.selectedOfflineMethod?.methodFields !=
                          null)
                        _PaymentInfoWidget(
                          methodInfo: orderProvider
                              .selectedOfflineMethod!
                              .methodInformations!,
                          key: ObjectKey(
                            orderProvider
                                .selectedOfflineMethod!
                                .methodInformations!,
                          ),
                          orderOfflineData: widget.orderOfflineData,
                          methodName:
                              orderProvider.selectedOfflineMethod!.methodName ??
                              "",
                        ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: orderProvider.isLoading
                    ? CustomLoaderWidget(color: Theme.of(context).primaryColor)
                    : CustomButtonWidget(
                        buttonText: getTranslated("confirm_payment", context),
                        onPressed: () {
                          if (orderProvider.formKey.currentState?.validate() ??
                              false) {
                            FocusScope.of(context).unfocus();

                            final offlinePaymentInfo = OfflinePaymentInfo(
                              methodFields: CheckOutHelper.getOfflineMethodJson(
                                orderProvider.selectedOfflineMethod?.methodFields,
                              ),
                              methodInformation: orderProvider.getOfflinePaymentData(),
                              paymentName: orderProvider.selectedOfflineMethod?.methodName,
                              paymentNote: orderProvider.selectedOfflineMethod?.paymentNote,
                              customerReceiptBase64: orderProvider.receiptBase64,
                            );

                            if (widget.orderId != null &&
                                widget.orderId != "null" &&
                                widget.orderId!.trim().isNotEmpty) {
                              orderProvider.storeOfflineData(
                                orderId: widget.orderId,
                                paymentInfo: offlinePaymentInfo,
                                fromOrderDetails: widget.orderOfflineData != null,
                                isPartial: widget.fromCheckout
                                    ? "0"
                                    : widget.partialAmount != null &&
                                          ((widget.totalAmount -
                                                  (widget.partialAmount ?? 0))) >
                                              0
                                      ? '1'
                                      : '0',
                                callback: _callback,
                              );
                            } else {
                              _placeOrderWithOfflineInfo(
                                orderProvider: orderProvider,
                                offlinePaymentInfo: offlinePaymentInfo,
                                context: context,
                              );
                            }
                          }
                        },
                      ),
              ),

              SizedBox(height: Dimensions.paddingSizeDefault),

              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          );
        },
      ),
    );
  }

  void _placeOrderWithOfflineInfo({
    required OrderProvider orderProvider,
    required OfflinePaymentInfo offlinePaymentInfo,
    required BuildContext context,
  }) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    CheckOutModel? checkOutData = orderProvider.getCheckOutData;
    final configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel;
    List<CartModel> cartList = Provider.of<CartProvider>(
      context,
      listen: false,
    ).cartList;
    List<Cart> carts = [];

    for (int index = 0; index < cartList.length; index++) {
      Cart cart = Cart(
        productId: cartList[index].id,
        price: cartList[index].price,
        discountAmount: cartList[index].discountedPrice,
        quantity: cartList[index].quantity,
        taxAmount: cartList[index].tax,
        variant: cartList[index].variation?.type ?? '',
        variation: (cartList[index].variation?.type != null &&
                cartList[index].variation!.type!.trim().isNotEmpty)
            ? [Variation(type: cartList[index].variation?.type)]
            : [],
      );
      carts.add(cart);
    }

    String? senderName;
    String? txRef;
    if (offlinePaymentInfo.methodInformation != null) {
      for (final map in offlinePaymentInfo.methodInformation!) {
        map.forEach((k, v) {
          if (senderName == null && (k.contains('مرسل') || k.contains('اسم') || k.contains('مودع') || k.contains('name') || k.contains('sender'))) {
            senderName = v;
          }
          if (txRef == null && (k.contains('اشعار') || k.contains('إشعار') || k.contains('سند') || k.contains('حوالة') || k.contains('عملية') || k.contains('ref') || k.contains('number') || k.contains('trans'))) {
            txRef = v;
          }
        });
      }
    }

    int branchId = 1;
    if (configModel?.branches != null &&
        configModel!.branches!.isNotEmpty &&
        orderProvider.branchIndex < configModel.branches!.length) {
      branchId = configModel.branches![orderProvider.branchIndex].id ?? 1;
    }

    PlaceOrderModel placeOrderBody = PlaceOrderModel(
      cart: carts,
      orderType: checkOutData?.orderType,
      couponCode: checkOutData?.couponCode,
      orderNote: checkOutData?.orderNote,
      branchId: branchId,
      deliveryAddressId: (orderProvider.addressIndex != -1 &&
              Provider.of<LocationProvider>(
                context,
                listen: false,
              ).addressList != null &&
              orderProvider.addressIndex <
                  Provider.of<LocationProvider>(
                    context,
                    listen: false,
                  ).addressList!.length)
          ? Provider.of<LocationProvider>(
              context,
              listen: false,
            ).addressList![orderProvider.addressIndex].id
          : null,
      distance: orderProvider.distance == -1 ? 0 : orderProvider.distance,
      couponDiscountAmount: Provider.of<CouponProvider>(
        context,
        listen: false,
      ).discount,
      timeSlotId: (orderProvider.timeSlots != null &&
              orderProvider.timeSlots!.isNotEmpty &&
              orderProvider.selectTimeSlot >= 0 &&
              orderProvider.selectTimeSlot < orderProvider.timeSlots!.length)
          ? orderProvider.timeSlots![orderProvider.selectTimeSlot].id
          : null,
      paymentMethod: 'offline_payment',
      paymentBy: senderName ?? offlinePaymentInfo.paymentName ?? 'العميل',
      transactionReference: txRef ?? 'سند تحويل',
      paymentNote: offlinePaymentInfo.paymentNote,
      paymentInfo: offlinePaymentInfo,
      deliveryDate: orderProvider.getDateList().isNotEmpty &&
              orderProvider.selectDateSlot < orderProvider.getDateList().length
          ? orderProvider.getDateList()[orderProvider.selectDateSlot]
          : '',
      couponDiscountTitle: '',
      orderAmount:
          (checkOutData?.amount ?? 0) +
          (orderProvider.deliveryCharge ?? 0),
      selectedDeliveryArea: orderProvider.selectedAreaID,
      isPartial: widget.partialAmount != null && widget.partialAmount! > 0 ? '1' : '0',
      bringChangeAmount: orderProvider.bringChangeAmount,
      isGuest: authProvider.isLoggedIn() ? "0" : "1",
      customerId: authProvider.isLoggedIn()
          ? profileProvider.userInfoModel?.id?.toString() ?? ''
          : '',
      paymentPlatform: kIsWeb ? 'web' : 'app',
      currencyCode: Provider.of<CurrencyProvider>(context, listen: false).selectedCurrency?.currencyCode,
    );

    orderProvider.placeOrder(
      placeOrderBody,
      (bool isSuccess, String message, String orderID) {
        if (isSuccess) {
          Navigator.of(context).pop();
          try {
            Provider.of<CartProvider>(Get.context ?? context, listen: false).clearCartList();
          } catch (_) {}
          final SplashProvider splashProvider = Provider.of<SplashProvider>(
            context,
            listen: false,
          );
          splashProvider.setPageIndex(0);
          RouteHelper.getOrderSuccessRoute(
            orderID,
            'success',
            action: RouteAction.pushReplacement,
          );
          showFlutterCustomToaster(
            "now_wait_for_your_payment_to_be_verified",
            toasterTitle: "your_payment_confirm_successfully",
            context: context,
            type: ToasterMessageType.success,
            duration: 4,
          );
        } else {
          showFlutterCustomToaster(message, context: context);
        }
      },
      context: context,
    );
  }

  void _callback(
    bool isSuccess,
    String message,
    String orderID,
    bool fromOderDetails,
  ) async {
    if (isSuccess) {
      final SplashProvider splashProvider = Provider.of<SplashProvider>(
        context,
        listen: false,
      );
      if (fromOderDetails) {
        Navigator.of(context).pop();
        showCustomSnackBarHelper(
          getTranslated("your_payment_update_successfully", context),
          isError: false,
        );
      } else {
        try {
          Provider.of<CartProvider>(Get.context ?? context, listen: false).clearCartList();
        } catch (_) {}
        splashProvider.setPageIndex(0);
        RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
        showFlutterCustomToaster(
          "now_wait_for_your_payment_to_be_verified",
          toasterTitle: "your_payment_confirm_successfully",
          context: context,
          type: ToasterMessageType.success,
          duration: 4,
        );
      }
    } else {
      showFlutterCustomToaster(message, context: context);
    }
  }
}

class _BillInfoWidget extends StatelessWidget {
  final List<MethodField> methodList;
  const _BillInfoWidget({required this.methodList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: methodList
          .map(
            (method) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${method.fieldName ?? ''} : ',
                    style: poppinsRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      method.fieldData ?? '',
                      style: poppinsMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PaymentInfoWidget extends StatefulWidget {
  final List<MethodInformation> methodInfo;
  final OfflinePaymentInformation? orderOfflineData;
  final String methodName;

  const _PaymentInfoWidget({
    super.key,
    required this.methodInfo,
    this.orderOfflineData,
    required this.methodName,
  });

  @override
  State<_PaymentInfoWidget> createState() => _PaymentInfoWidgetState();
}

class _PaymentInfoWidgetState extends State<_PaymentInfoWidget> {
  final TextEditingController noteTextController = TextEditingController();

  @override
  void initState() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      context,
      listen: false,
    );
    orderProvider.setReceiptFile(null, isUpdate: false);
    orderProvider.field = {};
    for (int i = 0; i < widget.methodInfo.length; i++) {
      if (widget.methodName == widget.orderOfflineData?.paymentName) {
        widget.orderOfflineData?.methodInformation?.forEach((element) {
          if (element.key == widget.methodInfo[i].informationName) {
            orderProvider.field.addAll({
              '${widget.methodInfo[i].informationName}': TextEditingController(
                text: element.value,
              ),
            });
          }
        });
      } else {
        orderProvider.field.addAll({
          '${widget.methodInfo[i].informationName}': TextEditingController(),
        });
      }
    }

    if (widget.orderOfflineData != null &&
        widget.orderOfflineData!.paymentNote != null) {
      noteTextController.text = widget.orderOfflineData!.paymentNote!;
    }

    super.initState();
  }

  @override
  void dispose() {
    noteTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(getTranslated('payment_info', context), style: poppinsMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
              color: Theme.of(context).hintColor.withValues(alpha: 0.04),
            ),
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: orderProvider.formKey,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orderProvider.field.length,
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeExtraSmall,
                          horizontal: 10,
                        ),

                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Dimensions.paddingSizeSmall,
                            children: [
                              Text(
                                widget.methodInfo[index].informationName ?? "",
                              ),
                              CustomTextFieldWidget(
                                onValidate:
                                    widget
                                        .methodInfo[index]
                                        .informationRequired!
                                    ? (String? value) {
                                        return value != null && value.isEmpty
                                            ? '${widget.methodInfo[index].informationName?.replaceAll("_", " ").toCapitalized()} ${getTranslated('is_required', context)}'
                                            : null;
                                      }
                                    : null,
                                isShowBorder: true,
                                controller: orderProvider
                                    .field['${widget.methodInfo[index].informationName}'],
                                hintText: widget
                                    .methodInfo[index]
                                    .informationPlaceholder,
                                fillColor: Theme.of(context).cardColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: Text(getTranslated('note', context)),
                    ),
                    SizedBox(height: Dimensions.paddingSizeSmall),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: CustomTextFieldWidget(
                        fillColor: Theme.of(context).cardColor,
                        isShowBorder: true,
                        controller: noteTextController,
                        hintText: getTranslated(
                          'enter_your_payment_note',
                          context,
                        ),
                        maxLines: 5,
                        inputType: TextInputType.multiline,
                        inputAction: TextInputAction.newline,
                        capitalization: TextCapitalization.sentences,
                        onChanged: (value) {
                          orderProvider.selectedOfflineMethod?.copyWith(
                            note: noteTextController.text,
                          );
                        },
                      ),
                    ),

                    SizedBox(height: Dimensions.paddingSizeDefault),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: Text(
                        getTranslated('transfer_receipt', context),
                        style: poppinsMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: orderProvider.receiptFile != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSizeSmall,
                                  ),
                                  child: Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withValues(alpha: 0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSizeSmall,
                                      ),
                                    ),
                                    child: kIsWeb
                                        ? Image.network(
                                            orderProvider.receiptFile!.path,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(
                                              orderProvider.receiptFile!.path,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: InkWell(
                                    onTap: () =>
                                        orderProvider.setReceiptFile(null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : InkWell(
                              onTap: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1200,
                                  maxHeight: 1200,
                                  imageQuality: 80,
                                );
                                if (picked != null) {
                                  orderProvider.setReceiptFile(picked);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeDefault,
                                  horizontal: Dimensions.paddingSizeSmall,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSizeSmall,
                                  ),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 32,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    Text(
                                      getTranslated(
                                        'attach_transfer_receipt',
                                        context,
                                      ),
                                      style: poppinsRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),

                    SizedBox(height: Dimensions.paddingSizeDefault),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: Dimensions.paddingSizeExtraLarge),
        ],
      ),
    );
  }
}

class _TransferInstructionsWidget extends StatefulWidget {
  final OfflinePaymentModel? selectedMethod;
  const _TransferInstructionsWidget({required this.selectedMethod});

  @override
  State<_TransferInstructionsWidget> createState() => _TransferInstructionsWidgetState();
}

class _TransferInstructionsWidgetState extends State<_TransferInstructionsWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final String methodName = widget.selectedMethod?.methodName ?? '';
    final String? customInstructions = widget.selectedMethod?.instructions;
    final bool hasCustomInstructions = customInstructions != null && customInstructions.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall + 2),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إرشادات إتمام التحويل',
                          style: poppinsBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: const Color(0xFF9A3412),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'اتبع هذه الخطوات لتأكيد طلبك بأسرع وقت',
                          style: poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Theme.of(context).hintColor,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFFEF3C7)),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasCustomInstructions)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                      ),
                      child: Text(
                        customInstructions.trim(),
                        style: poppinsRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          height: 1.5,
                        ),
                      ),
                    )
                  else ...[
                    _buildStepRow(
                      number: '1',
                      title: 'نسخ رقم الحساب',
                      description: 'انسخ رقم الحساب من الحساب الموضح أعلاه أو اضغط على نسخ للانتقال السريع إلى تطبيق $methodName.',
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    _buildStepRow(
                      number: '2',
                      title: 'التحويل من تطبيق ($methodName)',
                      description: 'قم بتحويل المبلغ المطلوب بدقة إلى الحساب الموضح مع التقاط صورة للإشعار.',
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    _buildStepRow(
                      number: '3',
                      title: 'تأكيد الحوالة إرفاق إثبات الدفع',
                      description: 'أرفق صورة الإشعار أو اكتب الرقم المرجعي للحوالة ثم اضغط "تأكيد الدفع".',
                    ),
                  ],
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xFF16A34A),
                          size: 20,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'ملاحظة: ',
                                  style: poppinsBold.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                                TextSpan(
                                  text: 'إذا أُغلق التطبيق تلقائياً أثناء وجودك في تطبيق البنك أو المحفظة لا تقلق! سيتم إعادتك تلقائياً إلى هذه الشاشة لمتابعة الدفع فور فتح التطبيق مجدداً.',
                                  style: poppinsRegular.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF166534),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFFDF4EC),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: poppinsBold.copyWith(
              fontSize: 11,
              color: const Color(0xFFD97706),
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: poppinsBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: poppinsRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).hintColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
