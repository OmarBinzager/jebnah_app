import 'package:flutter/material.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/models/cart_model.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../common/providers/product_provider.dart';
import '../../../common/widgets/custom_button_widget.dart';
import '../../../common/widgets/custom_directionality_widget.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../common/widgets/custom_zoom_widget.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/related_products_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../common/widgets/wish_button_widget.dart';
import '../../../features/product/widgets/details_app_bar_widget.dart';
import '../../../features/product/widgets/product_description_widget.dart';
import '../../../features/product/widgets/product_image_widget.dart';
import '../../../features/product/widgets/product_title_widget.dart';
import '../../../features/product/widgets/quantity_button_widget.dart';
import '../../../features/product/widgets/selected_product_widget.dart';
import '../../../features/product/widgets/variation_widget.dart';

import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/cart_helper.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../../../helper/price_converter_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/app_localization.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String? productId;
  final bool? fromSearch;
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.fromSearch = false,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  int _tabIndex = 0;
  bool showSeeMoreButton = true;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    final ProductProvider productProvider = Provider.of(context, listen: false);
    productProvider.getProductDetails(
      '${widget.productId}',
      searchQuery: widget.fromSearch!,
    );
    Provider.of<CartProvider>(context, listen: false).getCartData();
    Provider.of<CartProvider>(
      context,
      listen: false,
    ).onSelectProductStatus(0, false);

    productProvider.getProductReviews(
      id: widget.productId,
      offset: 1,
      isUpdate: false,
    );

    // 🔴 تحميل المنتجات المتعلقة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productProvider.getRelatedProducts(widget.productId!, offset: 1);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : DetailsAppBarWidget(
                key: UniqueKey(),
                title: 'product_details'.tr,
              ),

        body: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                double? priceWithQuantity = 0;
                double? priceWithQuantityWithoutDiscount = 0;
                CartModel? cartModel;

                if (productProvider.product != null) {
                  cartModel = CartHelper.getCartModel(
                    productProvider.product!,
                    quantity: cartProvider.quantity,
                    variationIndexList: cartProvider.variationIndex,
                  );

                  cartProvider.setExistData(
                    cartProvider.isExistInCart(cartModel),
                  );

                  final double? priceWithDiscount =
                      PriceConverterHelper.convertProductDiscount(
                        price: cartModel?.price,
                        discount: productProvider.product?.discount,
                        discountType: productProvider.product?.discountType,
                        categoryDiscount:
                            productProvider.product?.categoryDiscount,
                      ).discount;

                  if (cartProvider.cartIndex != null) {
                    priceWithQuantity =
                        (priceWithDiscount ?? 0) *
                        (cartProvider
                            .updatedCartList[cartProvider.cartIndex!]
                            .quantity!);
                    priceWithQuantityWithoutDiscount =
                        (cartModel?.price ?? 0) *
                        (cartProvider
                            .updatedCartList[cartProvider.cartIndex!]
                            .quantity!);
                  } else {
                    priceWithQuantity =
                        (priceWithDiscount ?? 0) * cartProvider.quantity;
                    priceWithQuantityWithoutDiscount =
                        (cartModel?.price ?? 0) * cartProvider.quantity;
                  }
                }

                return productProvider.product != null
                    ? !ResponsiveHelper.isDesktop(context)
                          ? Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: scrollController,
                                    physics: ResponsiveHelper.isMobilePhone()
                                        ? const BouncingScrollPhysics()
                                        : null,
                                    child: Center(
                                      child: SizedBox(
                                        width: Dimensions.webScreenWidth,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              children: [
                                                ProductImageWidget(
                                                  productModel:
                                                      productProvider.product,
                                                ),

                                                SizedBox(
                                                  height: 60,
                                                  child:
                                                      productProvider
                                                              .product
                                                              ?.image !=
                                                          null
                                                      ? SelectedImageWidget(
                                                          productModel:
                                                              productProvider
                                                                  .product,
                                                        )
                                                      : const SizedBox(),
                                                ),

                                                ProductTitleWidget(
                                                  product:
                                                      productProvider.product,
                                                  stock: cartModel?.stock,
                                                  cartIndex:
                                                      cartProvider.cartIndex,
                                                ),

                                                VariationWidget(
                                                  product:
                                                      productProvider.product,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height:
                                                  ResponsiveHelper.isDesktop(
                                                    context,
                                                  )
                                                  ? Dimensions.fontSizeMaxLarge
                                                  : Dimensions
                                                        .paddingSizeDefault,
                                            ),

                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                              child: ProductDescriptionWidget(
                                                scrollController:
                                                    scrollController,
                                                showSeeMoreButton:
                                                    showSeeMoreButton,
                                                tabIndex: _tabIndex,
                                                onTabChange: (int index) {
                                                  setState(() {
                                                    _tabIndex = index;
                                                  });
                                                },
                                                onChangeButtonStatus:
                                                    (bool status) {
                                                      setState(() {
                                                        showSeeMoreButton =
                                                            status;
                                                      });
                                                    },
                                              ),
                                            ),

                                            // 🔴 المنتجات المتعلقة - للجوال 🔴
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeDefault,
                                            ),
                                            RelatedProductsWidget(
                                              productId: widget.productId!,
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeDefault,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Center(
                                  child: SizedBox(
                                    width: Dimensions.webScreenWidth,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color!
                                                .withValues(alpha: 0.1),
                                            blurRadius: 10,
                                            offset: Offset(0, -1),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: Dimensions.paddingSizeSmall,
                                          horizontal:
                                              Dimensions.paddingSizeLarge,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${getTranslated('total_amount', context)}:',
                                                  style: poppinsMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color
                                                        ?.withValues(
                                                          alpha: 0.70,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall,
                                                ),

                                                Row(
                                                  children: [
                                                    CustomDirectionalityWidget(
                                                      child: Text(
                                                        PriceConverterHelper.convertPrice(
                                                          context,
                                                          priceWithQuantityWithoutDiscount,
                                                        ),
                                                        style: poppinsBold
                                                            .copyWith(
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),

                                                    CustomDirectionalityWidget(
                                                      child: Text(
                                                        PriceConverterHelper.convertPrice(
                                                          context,
                                                          priceWithQuantity,
                                                        ),
                                                        style: poppinsBold.copyWith(
                                                          color: Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                          fontSize: Dimensions
                                                              .fontSizeExtraLarge,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeDefault,
                                            ),

                                            Row(
                                              children: [
                                                if (((cartModel?.stock ?? 0) >
                                                    0)) ...[
                                                  Expanded(
                                                    flex: 3,
                                                    child: SizedBox(
                                                      height:
                                                          ResponsiveHelper.isTab(
                                                            context,
                                                          )
                                                          ? 60
                                                          : 50,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          QuantityButtonWidget(
                                                            isIncrement: false,
                                                            quantity:
                                                                cartProvider
                                                                    .quantity,
                                                            stock: cartModel
                                                                ?.stock,
                                                            cartIndex:
                                                                cartProvider
                                                                    .cartIndex,
                                                            maxOrderQuantity:
                                                                productProvider
                                                                    .product!
                                                                    .maximumOrderQuantity,
                                                          ),

                                                          Text(
                                                            '${cartProvider.cartIndex != null ? cartProvider.updatedCartList[cartProvider.cartIndex!].quantity : cartProvider.quantity}',
                                                            style: poppinsBold
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).primaryColor,
                                                                ),
                                                          ),

                                                          QuantityButtonWidget(
                                                            isIncrement: true,
                                                            quantity:
                                                                cartProvider
                                                                    .quantity,
                                                            stock: cartModel
                                                                ?.stock,
                                                            cartIndex:
                                                                cartProvider
                                                                    .cartIndex,
                                                            maxOrderQuantity:
                                                                productProvider
                                                                    .product!
                                                                    .maximumOrderQuantity,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeDefault,
                                                  ),
                                                ],
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeDefault,
                                                ),

                                                Expanded(
                                                  flex: 7,
                                                  child: CustomButtonWidget(
                                                    height:
                                                        ResponsiveHelper.isTab(
                                                          context,
                                                        )
                                                        ? 60
                                                        : 50,
                                                    buttonText:
                                                        _getCartButtonText(
                                                          cartProvider,
                                                          cartModel,
                                                          context,
                                                        ),
                                                    onPressed:
                                                        _onSubmitCartButton(
                                                          cartProvider,
                                                          cartModel,
                                                          context,
                                                        ),
                                                    textStyle: poppinsBold
                                                        .copyWith(
                                                          color: Theme.of(
                                                            context,
                                                          ).cardColor,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : CustomScrollView(
                              controller: scrollController,
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),
                                      Center(
                                        child: SizedBox(
                                          width: Dimensions.webScreenWidth,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: Dimensions
                                                                .paddingSizeSmall,
                                                          ),
                                                      child: Stack(
                                                        children: [
                                                          SizedBox(
                                                            height: 400,
                                                            width: double
                                                                .maxFinite,
                                                            child: CustomZoomWidget(
                                                              image: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusSizeTen,
                                                                    ),
                                                                child: CustomImageWidget(
                                                                  image:
                                                                      '${splashProvider.baseUrls?.productImageUrl}/${(productProvider.product?.image?.isNotEmpty ?? false) ? productProvider.product!.image![cartProvider.productSelect] : ''}',
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            ),
                                                          ),

                                                          Positioned(
                                                            top: 10,
                                                            right: 10,
                                                            child: WishButtonWidget(
                                                              product:
                                                                  productProvider
                                                                      .product,
                                                              edgeInset:
                                                                  const EdgeInsets.all(
                                                                    Dimensions
                                                                        .paddingSizeExtraSmall,
                                                                  ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall,
                                                    ),

                                                    SizedBox(
                                                      height: 70,
                                                      child:
                                                          productProvider
                                                                  .product!
                                                                  .image !=
                                                              null
                                                          ? SelectedImageWidget(
                                                              productModel:
                                                                  productProvider
                                                                      .product,
                                                            )
                                                          : const SizedBox(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 30),

                                              Expanded(
                                                flex: 6,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ProductTitleWidget(
                                                        product: productProvider
                                                            .product,
                                                        stock: cartModel?.stock,
                                                        cartIndex: cartProvider
                                                            .cartIndex,
                                                      ),

                                                      VariationWidget(
                                                        product: productProvider
                                                            .product,
                                                      ),
                                                      SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeLarge,
                                                      ),

                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${getTranslated('total_amount', context)}:',
                                                            style: poppinsMedium.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color
                                                                      ?.withValues(
                                                                        alpha:
                                                                            0.70,
                                                                      ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeExtraSmall,
                                                          ),

                                                          Row(
                                                            children: [
                                                              CustomDirectionalityWidget(
                                                                child: Text(
                                                                  PriceConverterHelper.convertPrice(
                                                                    context,
                                                                    priceWithQuantityWithoutDiscount,
                                                                  ),
                                                                  style: poppinsBold.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeOverLarge,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeSmall,
                                                              ),

                                                              CustomDirectionalityWidget(
                                                                child: Text(
                                                                  PriceConverterHelper.convertPrice(
                                                                    context,
                                                                    priceWithQuantity,
                                                                  ),
                                                                  style: poppinsBold.copyWith(
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).primaryColor,
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeMaxLarge,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 35,
                                                      ),

                                                      Row(
                                                        children: [
                                                          if (((cartModel
                                                                      ?.stock ??
                                                                  0) >
                                                              0)) ...[
                                                            Builder(
                                                              builder: (context) {
                                                                return Container(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        Dimensions
                                                                            .paddingSizeSmall,
                                                                    vertical:
                                                                        Dimensions
                                                                            .paddingSizeExtraSmall,
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      QuantityButtonWidget(
                                                                        isIncrement:
                                                                            false,
                                                                        quantity:
                                                                            cartProvider.quantity,
                                                                        stock: cartModel
                                                                            ?.stock,
                                                                        cartIndex:
                                                                            cartProvider.cartIndex,
                                                                        maxOrderQuantity: productProvider
                                                                            .product!
                                                                            .maximumOrderQuantity,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            15,
                                                                      ),

                                                                      Consumer<
                                                                        CartProvider
                                                                      >(
                                                                        builder:
                                                                            (
                                                                              context,
                                                                              cart,
                                                                              child,
                                                                            ) {
                                                                              return Text(
                                                                                cart.cartIndex !=
                                                                                        null
                                                                                    ? cart.updatedCartList[cart.cartIndex!].quantity.toString()
                                                                                    : cart.quantity.toString(),
                                                                                style: poppinsBold.copyWith(
                                                                                  color: Theme.of(
                                                                                    context,
                                                                                  ).primaryColor,
                                                                                ),
                                                                              );
                                                                            },
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            15,
                                                                      ),

                                                                      QuantityButtonWidget(
                                                                        scrollController:
                                                                            scrollController,
                                                                        isIncrement:
                                                                            true,
                                                                        quantity:
                                                                            cartProvider.quantity,
                                                                        stock: cartModel
                                                                            ?.stock,
                                                                        cartIndex:
                                                                            cartProvider.cartIndex,
                                                                        maxOrderQuantity: productProvider
                                                                            .product
                                                                            ?.maximumOrderQuantity,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            const SizedBox(
                                                              width: Dimensions
                                                                  .paddingSizeDefault,
                                                            ),
                                                          ],

                                                          Builder(
                                                            builder: (context) => Center(
                                                              child: SizedBox(
                                                                width: 200,
                                                                child: CustomButtonWidget(
                                                                  icon: Icons
                                                                      .shopping_cart,
                                                                  buttonText:
                                                                      _getCartButtonText(
                                                                        cartProvider,
                                                                        cartModel,
                                                                        context,
                                                                      ),
                                                                  onPressed:
                                                                      _onSubmitCartButton(
                                                                        cartProvider,
                                                                        cartModel,
                                                                        context,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      //Description
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraLarge,
                                      ),

                                      Center(
                                        child: SizedBox(
                                          width: Dimensions.webScreenWidth,
                                          child: ProductDescriptionWidget(
                                            scrollController: scrollController,
                                            showSeeMoreButton:
                                                showSeeMoreButton,
                                            tabIndex: _tabIndex,
                                            onTabChange: (int index) {
                                              setState(() {
                                                _tabIndex = index;
                                              });
                                            },
                                            onChangeButtonStatus:
                                                (bool status) {
                                                  setState(() {
                                                    showSeeMoreButton = status;
                                                  });
                                                },
                                          ),
                                        ),
                                      ),

                                      // 🔴 المنتجات المتعلقة - للديسكتوب 🔴
                                      const SizedBox(
                                        height: Dimensions.paddingSizeDefault,
                                      ),
                                      RelatedProductsWidget(
                                        productId: widget.productId!,
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeDefault,
                                      ),
                                    ],
                                  ),
                                ),

                                const FooterWebWidget(
                                  footerType: FooterType.sliver,
                                ),
                              ],
                            )
                    : Center(
                        child: CustomLoaderWidget(
                          color: Theme.of(context).primaryColor,
                        ),
                      );
              },
            );
          },
        ),
      ),
    );
  }

  VoidCallback? _onSubmitCartButton(
    CartProvider cartProvider,
    CartModel? cartModel,
    BuildContext context,
  ) {
    return ((cartProvider.pendingCartList.isNotEmpty ||
                cartProvider.cartIndex == null) &&
            (cartModel?.stock ?? 0) > 0)
        ? () {
            if (cartProvider.pendingCartList.isNotEmpty) {
              cartProvider.updateCart();
              showCustomSnackBarHelper('cart_updated'.tr, isError: false);
            } else {
              if (cartProvider.cartIndex == null &&
                  (cartModel?.stock ?? 0) > 0) {
                cartProvider.addToCart(cartModel!);
                showCustomSnackBarHelper(
                  getTranslated('added_to_cart', context),
                  isError: false,
                );
              } else {
                showCustomSnackBarHelper(
                  getTranslated('already_added', context),
                );
              }
            }
          }
        : (cartProvider.cartIndex != null)
        ? () {
            showCustomSnackBarHelper('cart_updated'.tr, isError: false);
          }
        : null;
  }

  String _getCartButtonText(
    CartProvider cartProvider,
    CartModel? cartModel,
    BuildContext context,
  ) {
    if (cartProvider.cartIndex != null) {
      return getTranslated(
        cartProvider.pendingCartList.isEmpty ? 'update_cart' : 'update_cart',
        context,
      );
    }

    if ((cartModel?.stock ?? 0) <= 0) {
      return getTranslated('out_of_stock', context);
    }

    return getTranslated('add_to_card', context);
  }
}
