import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../common/models/config_model.dart';
import '../../../common/models/place_order_model.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../features/order/domain/models/offline_payment_model.dart';
import '../../../features/order/widgets/bring_change_input_widget.dart';
import '../../../features/wallet_and_loyalty/widgets/add_fund_dialogue_widget.dart';
import '../../../helper/price_converter_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_button_widget.dart';
import '../../../features/checkout/widgets/offline_payment_widget.dart';
import '../../../features/checkout/widgets/payment_button_widget.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class PaymentMethodBottomSheetWidget extends StatefulWidget {
  final double totalPrice;
  final double? weight;
  final String? orderId;
  final bool isAlreadyPartialApplied;
  const PaymentMethodBottomSheetWidget({
    super.key,
    required this.totalPrice,
    this.weight,
    this.orderId,
    this.isAlreadyPartialApplied = false,
  });

  @override
  State<PaymentMethodBottomSheetWidget> createState() =>
      _PaymentMethodBottomSheetWidgetState();
}

class _PaymentMethodBottomSheetWidgetState
    extends State<PaymentMethodBottomSheetWidget> {
  String partialPaymentCombinator = "all";
  final JustTheController? toolTip = JustTheController();
  TextEditingController? _bringAmountController;
  List<PaymentMethod> paymentList = [];
  int? _paymentMethodIndex;
  double? _partialAmount;
  PaymentMethod? _paymentMethod;
  OfflinePaymentModel? _selectedOfflineMethod;
  List<Map<String, String>>? _selectedOfflineValue;

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final ConfigModel configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel!;

    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: 550,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SafeArea(
                bottom: !kIsWeb && Platform.isAndroid,
                child: Container(
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
                        : BorderRadius.all(
                            Radius.circular(Dimensions.radiusSizeDefault),
                          ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  child: SafeArea(
                    child: Consumer<OrderProvider>(
                      builder: (ctx, orderProvider, _) {
                        double bottomPadding = MediaQuery.of(
                          context,
                        ).padding.bottom;

                        double walletBalance =
                            profileProvider.userInfoModel?.walletBalance ?? 0;
                        bool isPartialPayment =
                            widget.totalPrice > walletBalance;
                        bool isWalletSelectAndNotPartial =
                            _paymentMethodIndex == 0 && !isPartialPayment;

                        bool hideCOD =
                            isWalletSelectAndNotPartial ||
                            (_partialAmount != null &&
                                (partialPaymentCombinator ==
                                        "digital_payment" ||
                                    partialPaymentCombinator ==
                                        "offline_payment"));

                        bool hideDigital =
                            isWalletSelectAndNotPartial ||
                            (_partialAmount != null &&
                                (partialPaymentCombinator == "cod" ||
                                    partialPaymentCombinator ==
                                        "offline_payment"));

                        bool hideOffline =
                            isWalletSelectAndNotPartial ||
                            (_partialAmount != null &&
                                (partialPaymentCombinator == "cod" ||
                                    partialPaymentCombinator ==
                                        "digital_payment"));

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),
                            !ResponsiveHelper.isDesktop(context)
                                ? Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: 4,
                                      width: 35,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).disabledColor.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: const Icon(Icons.clear, size: 20),
                                ),
                              ),
                            ),

                            Text(
                              getTranslated('choose_payment_method', context),
                              style: poppinsSemiBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),
                            Text(
                              getTranslated('total_bill', context),
                              style: poppinsRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              PriceConverterHelper.convertPrice(
                                context,
                                widget.totalPrice,
                              ),
                              style: poppinsBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),

                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),

                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height * 0.2,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.5,
                              ),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.paddingSizeLarge *
                                        (ResponsiveHelper.isDesktop(context)
                                            ? 2
                                            : 1),
                                  ),
                                  child: Column(
                                    children: [
                                      configModel.walletStatus! &&
                                              authProvider.isLoggedIn() &&
                                              walletBalance > 0 &&
                                              !widget.isAlreadyPartialApplied
                                          ? PaymentButtonWidget(
                                              icon: Images.walletIcon,
                                              isWallet: true,
                                              title: getTranslated(
                                                'pay_via_wallet',
                                                context,
                                              ),
                                              isSelected:
                                                  _paymentMethodIndex == 0,
                                              hidePaymentMethod: false,
                                              walletBalance: walletBalance,
                                              totalPrice: widget.totalPrice,
                                              partialAmount: _partialAmount,
                                              chooseAnyPayment:
                                                  _paymentMethodIndex != null ||
                                                  _paymentMethod != null,
                                              callBack:
                                                  ({
                                                    int? paymentMethodIndex,
                                                    double? partialAmount,
                                                  }) {
                                                    setState(() {
                                                      _paymentMethodIndex =
                                                          paymentMethodIndex;
                                                      _partialAmount =
                                                          partialAmount;
                                                      _paymentMethod = null;
                                                      _bringAmountController
                                                              ?.text =
                                                          "";
                                                      orderProvider
                                                          .updateBringChangeInputOptionStatus(
                                                            false,
                                                            isUpdate: false,
                                                          );
                                                      orderProvider
                                                          .setBringChangeAmount();
                                                    });
                                                  },
                                            )
                                          : const SizedBox(),

                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),

                                      configModel.cashOnDelivery!
                                          ? PaymentButtonWidget(
                                              icon: Images.cashOnDelivery,
                                              title: getTranslated(
                                                'cash_on_delivery',
                                                context,
                                              ),
                                              walletBalance: walletBalance,
                                              hidePaymentMethod: hideCOD,
                                              totalPrice: widget.totalPrice,
                                              isSelected:
                                                  _paymentMethodIndex == 1,
                                              chooseAnyPayment:
                                                  _paymentMethodIndex != null ||
                                                  _paymentMethod != null,
                                              callBack:
                                                  ({
                                                    int? paymentMethodIndex,
                                                    double? partialAmount,
                                                  }) {
                                                    setState(() {
                                                      _paymentMethodIndex =
                                                          paymentMethodIndex;
                                                      _paymentMethod = null;
                                                      _selectedOfflineValue =
                                                          null;
                                                      _selectedOfflineMethod =
                                                          null;
                                                    });
                                                  },
                                            )
                                          : const SizedBox(),

                                      if (configModel.cashOnDelivery!)
                                        BringChangeInputWidget(
                                          amountController:
                                              _bringAmountController,
                                          hidePaymentMethod: hideCOD,
                                        ),

                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),
                                      if (paymentList.isNotEmpty)
                                        Opacity(
                                          opacity: (hideOffline && hideDigital)
                                              ? 0.4
                                              : 1,
                                          child: Stack(
                                            children: [
                                              PaymentMethodView(
                                                toolTip: toolTip,
                                                paymentList: paymentList,
                                                hideDigital: hideDigital,
                                                hideOffline: hideOffline,
                                                selectedPaymentMethod:
                                                    _paymentMethod?.getWay ??
                                                    _paymentMethod?.getWayTitle,
                                                selectedOfflineMethod:
                                                    _selectedOfflineMethod,
                                                selectedOfflineValue:
                                                    _selectedOfflineValue,
                                                onTap: (index) {
                                                  setState(() {
                                                    _paymentMethod =
                                                        paymentList[index];
                                                    _paymentMethodIndex = null;
                                                    _selectedOfflineMethod =
                                                        null;
                                                    _selectedOfflineValue =
                                                        null;
                                                    _bringAmountController
                                                            ?.text =
                                                        "";
                                                    orderProvider
                                                        .updateBringChangeInputOptionStatus(
                                                          false,
                                                          isUpdate: false,
                                                        );
                                                    orderProvider
                                                        .setBringChangeAmount();
                                                  });
                                                },

                                                callBack:
                                                    ({
                                                      OfflinePaymentModel?
                                                      offlinePaymentModel,
                                                      List<Map<String, String>>?
                                                      selectedOfflineValue,
                                                    }) {
                                                      setState(() {
                                                        _selectedOfflineValue =
                                                            selectedOfflineValue;
                                                        _selectedOfflineMethod =
                                                            offlinePaymentModel;
                                                      });
                                                    },
                                              ),

                                              if (hideOffline && hideDigital)
                                                Positioned.fill(
                                                  child: Container(
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    Dimensions.paddingSizeLarge *
                                    (ResponsiveHelper.isDesktop(context)
                                        ? 2
                                        : 1),
                              ),
                              child: orderProvider.isLoading
                                  ? CustomLoaderWidget(
                                      color: Theme.of(context).primaryColor,
                                    )
                                  : CustomButtonWidget(
                                      buttonText: getTranslated(
                                        'proceed',
                                        context,
                                      ),
                                      onPressed:
                                          _paymentMethodIndex == null &&
                                                  _paymentMethod == null ||
                                              (_paymentMethod != null &&
                                                  _paymentMethod?.type ==
                                                      'offline' &&
                                                  _selectedOfflineMethod ==
                                                      null)
                                          ? null
                                          : () {
                                              if (_paymentMethod?.type == 'offline') {
                                                Navigator.of(context).pop();
                                                ResponsiveHelper().showDialogOrBottomSheet(
                                                  context,
                                                  isScrollControlled: true,
                                                  OfflinePaymentWidget(
                                                    totalAmount:
                                                        widget.totalPrice,
                                                    selectedOfflineMethod:
                                                        _selectedOfflineMethod,
                                                    partialAmount:
                                                        isPartialPayment &&
                                                            _partialAmount !=
                                                                null
                                                        ? (widget.totalPrice -
                                                              walletBalance)
                                                        : widget.totalPrice,
                                                    orderId: widget.orderId,
                                                    fromCheckout: true,
                                                  ),
                                                );
                                               } else {
                                                if (_paymentMethodIndex == 1) {
                                                  orderProvider
                                                      .setBringChangeAmount(
                                                        amountController:
                                                            _bringAmountController,
                                                      );
                                                }
                                                orderProvider.savePaymentMethod(
                                                  index: _paymentMethodIndex,
                                                  method: _paymentMethod,
                                                  partialAmount: _partialAmount,
                                                  selectedOfflineValue:
                                                      _selectedOfflineValue,
                                                  selectedOfflineMethod:
                                                      _selectedOfflineMethod,
                                                );

                                                /// Switch payment method for existing order
                                                if (widget.orderId != null &&
                                                    widget.orderId != "null") {
                                                  String paymentMethod =
                                                      orderProvider
                                                              .selectedOfflineValue !=
                                                          null
                                                      ? 'offline_payment'
                                                      : orderProvider
                                                            .selectedPaymentMethod!
                                                            .getWay!;

                                                  if (paymentMethod ==
                                                          'wallet_payment' ||
                                                      paymentMethod ==
                                                          'cash_on_delivery' ||
                                                      paymentMethod ==
                                                          'offline_payment') {
                                                    orderProvider.switchPaymentMethod(
                                                      orderId: widget.orderId!,
                                                      paymentMethod: orderProvider
                                                          .selectedPaymentMethod!
                                                          .getWay!,
                                                      isPartial:
                                                          _partialAmount !=
                                                                  null &&
                                                              _partialAmount! >
                                                                  0
                                                          ? 1
                                                          : 0,
                                                      bringChangeAmount:
                                                          double.tryParse(
                                                            _bringAmountController
                                                                    ?.text ??
                                                                "0",
                                                          ),
                                                    );
                                                  } else {
                                                    _switchOfflineToDigital(
                                                      orderAmount:
                                                          widget.totalPrice,
                                                      paymentMethod:
                                                          paymentMethod,
                                                      partialAmount:
                                                          _partialAmount,
                                                      orderId:
                                                          widget.orderId ?? "",
                                                    );
                                                  }
                                                } else {
                                                  Navigator.of(context).pop();
                                                }
                                              }
                                            },
                                    ),
                            ),

                            SizedBox(
                              height: bottomPadding > 0
                                  ? 0
                                  : Dimensions.paddingSizeDefault,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _bringAmountController = TextEditingController();

    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );
    final ConfigModel configModel = splashProvider.configModel!;
    splashProvider.getOfflinePaymentMethod(false);

    partialPaymentCombinator =
        configModel.partialPaymentCombineWith?.toLowerCase() ?? "all";

    paymentList.addAll(configModel.activePaymentMethodList ?? []);

    if (configModel.isOfflinePayment!) {
      paymentList.add(
        PaymentMethod(
          getWay: 'offline',
          getWayTitle: getTranslated('offline', context),
          type: 'offline',
          getWayImage: Images.offlinePayment,
        ),
      );
    }
    _initializeData();
  }

  void _initializeData() {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      context,
      listen: false,
    );
    final ConfigModel? configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel;

    if (orderProvider.paymentMethodIndex == null &&
        orderProvider.selectedPaymentMethod == null) {
      orderProvider.loadSavedPaymentMethod(
        configModel: configModel,
        notify: false,
      );
    }

    _paymentMethodIndex = orderProvider.paymentMethodIndex;
    _partialAmount = orderProvider.partialAmount;
    _paymentMethod = orderProvider.paymentMethod;
    _selectedOfflineMethod = orderProvider.selectedOfflineMethod;
    _selectedOfflineValue = orderProvider.selectedOfflineValue;

    if (orderProvider.paymentMethodIndex != 1) {
      orderProvider.setBringChangeAmount(isUpdate: false);
      orderProvider.updateBringChangeInputOptionStatus(false, isUpdate: false);
    } else {
      _bringAmountController?.text =
          "${orderProvider.bringChangeAmount?.floor() ?? ""}";
    }
  }

  Future<void> _switchOfflineToDigital({
    required String paymentMethod,
    required double orderAmount,
    double? partialAmount,
    required String orderId,
  }) async {
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final OrderProvider orderProvider = Provider.of<OrderProvider>(
      context,
      listen: false,
    );

    final String? hostname = html.window.location.hostname;
    final String protocol = html.window.location.protocol;
    final String port = html.window.location.port;

    PlaceOrderModel placeOrderBody = PlaceOrderModel(
      paymentMethod: paymentMethod,
      orderAmount: orderAmount,
      isPartial: partialAmount == null ? '0' : '1',
      isGuest: authProvider.getGuestId() != null ? '1' : '0',
      customerId: authProvider.isLoggedIn()
          ? profileProvider.userInfoModel?.id.toString()
          : '',
      paymentPlatform: kIsWeb ? 'web' : 'app',
      callBack: ResponsiveHelper.isWeb()
          ? '$protocol//$hostname${kDebugMode ? ':$port' : ''}${RouteHelper.orderDetails}'
          : '${AppConstants.baseUrl}${RouteHelper.orderDetails}',
      orderId: orderId,
      shwitchToDigital: '1',
    );

    final paymentUrl = await orderProvider.placeDigitalOrder(
      context,
      placeOrderBody,
    );

    if (paymentUrl != null) {
      if (ResponsiveHelper.isWeb()) {
        html.window.open(paymentUrl, "_self");
      } else {
        RouteHelper.getPaymentRoute(
          url: paymentUrl,
          id: orderId,
          action: RouteAction.pushNamedAndRemoveUntil,
        );
      }
    }
  }
}
