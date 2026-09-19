import 'package:flutter/material.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../common/providers/theme_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_button_widget.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import 'package:provider/provider.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String? orderID;
  final int? status;

  const OrderSuccessScreen({super.key, required this.orderID, this.status});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  // bool _isReload = true;
  @override
  void initState() {
    if (widget.status == 0) {
      Provider.of<OrderProvider>(
        context,
        listen: false,
      ).trackOrder(widget.orderID, null, context, false, isUpdate: false);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: ((canPop, _) {
        RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
      }),
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : null,
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            double total = 0;
            bool success = true;

            if (orderProvider.trackModel != null &&
                splashProvider.configModel?.loyaltyPointItemPurchasePoint !=
                    null) {
              total =
                  (((orderProvider.trackModel?.orderAmount ?? 0) / 100) *
                  (splashProvider.configModel?.loyaltyPointItemPurchasePoint ??
                      0));
            }

            return orderProvider.isLoading
                ? CustomLoaderWidget(color: Theme.of(context).primaryColor)
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child: SizedBox(
                            height: ResponsiveHelper.isDesktop(context)
                                ? null
                                : MediaQuery.sizeOf(context).height,
                            width: ResponsiveHelper.isDesktop(context)
                                ? MediaQuery.of(context).size.width * 0.3
                                : Dimensions.webScreenWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (ResponsiveHelper.isDesktop(context))
                                  const SizedBox(
                                    height: Dimensions.paddingSizeExtraLarge,
                                  ),

                                widget.status == 0
                                    ? Image.asset(
                                        Images.orderPlaced,
                                        width: 150,
                                        height: 150,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : const Icon(
                                        Icons.sms_failed_outlined,
                                        size: 150,
                                      ),

                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),

                                Text(
                                  getTranslated(
                                    widget.status == 0
                                        ? 'order_placed_successfully'
                                        : widget.status == 1
                                        ? 'payment_failed'
                                        : 'payment_cancelled',
                                    context,
                                  ),
                                  style: poppinsMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                if (widget.status == 0 &&
                                    widget.orderID != 'null')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${getTranslated('order_id', context)}:  #${widget.orderID}',
                                        style: poppinsRegular.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color
                                              ?.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 30),

                                (success &&
                                        Provider.of<AuthProvider>(
                                          context,
                                          listen: false,
                                        ).isLoggedIn() &&
                                        Provider.of<SplashProvider>(
                                          context,
                                        ).configModel!.loyaltyPointStatus! &&
                                        total.floor() > 0)
                                    ? Column(
                                        children: [
                                          Image.asset(
                                            Provider.of<ThemeProvider>(
                                                  context,
                                                  listen: false,
                                                ).darkTheme
                                                ? Images.gifBoxDark
                                                : Images.gifBox,
                                            width: 150,
                                            height: 150,
                                          ),

                                          Text(
                                            getTranslated(
                                              'congratulations',
                                              context,
                                            ),
                                            style: poppinsMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: Dimensions.paddingSizeSmall,
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeLarge,
                                            ),
                                            child: Text(
                                              '${getTranslated('you_have_earned', context)} ${total.floor().toString()} ${getTranslated('points_it_will_add_to', context)}',
                                              style: poppinsRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color: Theme.of(
                                                  context,
                                                ).disabledColor,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),

                                if (widget.status == 0)
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeLarge,
                                      ),
                                      child: CustomButtonWidget(
                                        buttonText: getTranslated(
                                          'order_track',
                                          context,
                                        ),
                                        onPressed: () {
                                          RouteHelper.getOrderTrackingRoute(
                                            int.parse(widget.orderID!),
                                            null,
                                            action: RouteAction
                                                .pushNamedAndRemoveUntil,
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeLarge,
                                    ),
                                    child: CustomButtonWidget(
                                      buttonText: getTranslated(
                                        'back_home',
                                        context,
                                      ),
                                      onPressed: () {
                                        splashProvider.setPageIndex(0);
                                        RouteHelper.getMainRoute(
                                          action: RouteAction
                                              .pushNamedAndRemoveUntil,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const FooterWebWidget(footerType: FooterType.sliver),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
