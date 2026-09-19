import 'package:flutter/material.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../features/cart/widgets/cart_button_widget.dart';
import '../../../features/cart/widgets/cart_product_list_widget.dart';
import '../../../helper/cart_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../features/coupon/providers/coupon_provider.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../common/widgets/app_bar_base_widget.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/no_data_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_details_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _couponController.clear();
    Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
    Provider.of<OrderProvider>(
      context,
      listen: false,
    ).setOrderType('delivery', notify: false);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel;
    final CartProvider cartProvider = Provider.of<CartProvider>(
      context,
      listen: false,
    );

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isMobilePhone()
            ? null
            : (ResponsiveHelper.isDesktop(context)
                      ? const PreferredSize(
                          preferredSize: Size.fromHeight(120),
                          child: WebAppBarWidget(),
                        )
                      : const AppBarBaseWidget())
                  as PreferredSizeWidget?,
        body: Center(
          child: Consumer<CouponProvider>(
            builder: (context, couponProvider, _) {
              return Consumer<CartProvider>(
                builder: (context, cart, child) {
                  double itemPrice = 0;
                  double discount = 0;
                  double tax = 0;

                  for (var cartModel in cart.cartList) {
                    itemPrice =
                        itemPrice +
                        ((cartModel.price ?? 0) * (cartModel.quantity ?? 0));
                    discount =
                        discount +
                        ((cartModel.discount ?? 0) * (cartModel.quantity ?? 0));
                    tax =
                        tax +
                        ((cartModel.tax ?? 0) * (cartModel.quantity ?? 0));
                  }

                  double subTotal =
                      itemPrice +
                      ((configModel?.isVatTexInclude ?? false) ? 0 : tax);
                  bool isFreeDelivery =
                      subTotal >= (configModel?.freeDeliveryOverAmount ?? 0) &&
                          (configModel?.freeDeliveryStatus ?? false) ||
                      couponProvider.coupon?.couponType == 'free_delivery';

                  double total =
                      subTotal -
                      discount -
                      (Provider.of<CouponProvider>(context).discount ?? 0);

                  double weight = 0.0;
                  weight = isFreeDelivery
                      ? 0
                      : CartHelper.weightCalculation(cartProvider.cartList);

                  return cart.cartList.isNotEmpty
                      ? !ResponsiveHelper.isDesktop(context)
                            ? Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeDefault,
                                        vertical: Dimensions.paddingSizeSmall,
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          width: Dimensions.webScreenWidth,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Consumer<CartProvider>(
                                                    builder:
                                                        (
                                                          context,
                                                          cartProvider,
                                                          _,
                                                        ) {
                                                          return Text(
                                                            '${cartProvider.getTotalCartQuantity()} ${getTranslated('items', context)} ${getTranslated('added', context)}',
                                                            style:
                                                                poppinsMedium,
                                                          );
                                                        },
                                                  ),

                                                  InkWell(
                                                    onTap: () {
                                                      Provider.of<
                                                            SplashProvider
                                                          >(
                                                            context,
                                                            listen: false,
                                                          )
                                                          .setPageIndex(1);
                                                    },
                                                    child: Row(
                                                      spacing: Dimensions
                                                          .paddingSizeSmall,
                                                      children: [
                                                        Text(
                                                          getTranslated(
                                                            'add_more',
                                                            context,
                                                          ),
                                                        ),

                                                        Icon(
                                                          Icons
                                                              .add_circle_outline_sharp,
                                                          color: Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                          size: 14,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeDefault,
                                              ),

                                              const CartProductListWidget(),

                                              CartDetailsWidget(
                                                couponController:
                                                    _couponController,
                                                total: total,
                                                isFreeDelivery: isFreeDelivery,
                                                itemPrice: itemPrice,
                                                tax: tax,
                                                discount: discount,
                                              ),
                                              const SizedBox(height: 40),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).hintColor.withValues(alpha: 0.1),
                                          blurRadius: 15,
                                          spreadRadius: 0,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                      color: Theme.of(context).cardColor,
                                    ),
                                    child: CartButtonWidget(
                                      subTotal: subTotal,
                                      configModel: configModel,
                                      itemPrice: itemPrice,
                                      total: total,
                                      isFreeDelivery: isFreeDelivery,
                                      discount: discount,
                                      tax: tax,
                                      weight: weight,
                                    ),
                                  ),
                                ],
                              )
                            : CustomScrollView(
                                controller: _scrollController,
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Center(
                                      child: SizedBox(
                                        width: Dimensions.webScreenWidth,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical:
                                                Dimensions.paddingSizeLarge,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 6,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: Dimensions
                                                            .paddingSizeLarge,
                                                        right: Dimensions
                                                            .paddingSizeLarge,
                                                        top: Dimensions
                                                            .paddingSizeLarge,
                                                        bottom: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(
                                                      context,
                                                    ).cardColor,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                          Radius.circular(
                                                            Dimensions
                                                                .radiusSizeDefault,
                                                          ),
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withValues(
                                                              alpha: 0.01,
                                                            ),
                                                        spreadRadius: 1,
                                                        blurRadius: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  child: CartProductListWidget(
                                                    scrollController:
                                                        _scrollController,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width:
                                                    Dimensions.paddingSizeLarge,
                                              ),

                                              Expanded(
                                                flex: 4,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    CartDetailsWidget(
                                                      couponController:
                                                          _couponController,
                                                      total: total,
                                                      isFreeDelivery:
                                                          isFreeDelivery,
                                                      itemPrice: itemPrice,
                                                      tax: tax,
                                                      discount: discount,
                                                    ),
                                                    const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeLarge,
                                                    ),

                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    ).hintColor
                                                                    .withValues(
                                                                      alpha:
                                                                          0.1,
                                                                    ),
                                                            blurRadius: 15,
                                                            spreadRadius: 0,
                                                            offset: Offset(
                                                              0,
                                                              5,
                                                            ),
                                                          ),
                                                        ],
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                      ),
                                                      child: CartButtonWidget(
                                                        subTotal: subTotal,
                                                        configModel:
                                                            configModel,
                                                        itemPrice: itemPrice,
                                                        total: total,
                                                        isFreeDelivery:
                                                            isFreeDelivery,
                                                        discount: discount,
                                                        tax: tax,
                                                        weight: weight,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const FooterWebWidget(
                                    footerType: FooterType.sliver,
                                  ),
                                ],
                              )
                      : NoDataWidget(
                          image: Images.favouriteNoDataImage,
                          title: getTranslated('empty_shopping_bag', context),
                        );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
