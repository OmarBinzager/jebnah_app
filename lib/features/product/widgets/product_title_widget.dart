import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/models/cart_model.dart';
import '../../../common/models/product_model.dart';
import '../../../common/providers/cart_provider.dart';

import '../../../common/widgets/custom_directionality_widget.dart';
import '../../../common/widgets/custom_image_widget.dart';

import '../../../helper/cart_helper.dart';
import '../../../helper/price_converter_helper.dart';
import '../../../helper/responsive_helper.dart';

import '../../../localization/language_constraints.dart';

import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';

import '../../brand/providers/brand_provider.dart';
import '../../home/providers/seller_provider.dart';
import '../../splash/providers/splash_provider.dart';

class ProductTitleWidget extends StatelessWidget {
  final Product? product;
  final int? stock;
  final int? cartIndex;
  final CartModel? cartModel;

  const ProductTitleWidget({
    super.key,
    required this.product,
    required this.stock,
    required this.cartIndex,
    this.cartModel,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // Calculate the active selected price (from cartModel or by looking up current variation)
        final activeCartModel = (product != null
                ? CartHelper.getCartModel(
                    product!,
                    variationIndexList: cartProvider.variationIndex,
                  )
                : null) ??
            cartModel;

        double? currentPrice;
        double? currentPriceWithDiscount;

        if (activeCartModel != null &&
            activeCartModel.price != null &&
            activeCartModel.price! > 0) {
          currentPrice = activeCartModel.price;
          currentPriceWithDiscount = PriceConverterHelper.convertProductDiscount(
            price: currentPrice,
            discount: product?.discount,
            discountType: product?.discountType,
            categoryDiscount: product?.categoryDiscount,
          ).discount;
        } else if (product?.variations?.isNotEmpty ?? false) {
          currentPrice = product!.variations!.first.price ?? product!.price ?? 0;
          currentPriceWithDiscount = PriceConverterHelper.convertProductDiscount(
            price: currentPrice,
            discount: product?.discount,
            discountType: product?.discountType,
            categoryDiscount: product?.categoryDiscount,
          ).discount;
        } else {
          currentPrice = product?.price ?? 0;
          currentPriceWithDiscount = PriceConverterHelper.convertProductDiscount(
            price: currentPrice,
            discount: product?.discount,
            discountType: product?.discountType,
            categoryDiscount: product?.categoryDiscount,
          ).discount;
        }

        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// PRODUCT NAME
              Text(
                product?.name ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: poppinsBold.copyWith(
                  fontSize: ResponsiveHelper.isDesktop(context) ? 26 : 22,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 14),

              /// BRAND + SELLER
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildBrandChip(context),
                  _buildSellerChip(context),
                ],
              ),

              const SizedBox(height: 18),

              /// PRICE
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /// DISCOUNT PRICE / CURRENT VARIATION PRICE
                  CustomDirectionalityWidget(
                    child: Text(
                      PriceConverterHelper.convertPrice(
                        context,
                        currentPriceWithDiscount,
                      ),
                      style: poppinsBold.copyWith(
                        fontSize: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// ORIGINAL PRICE (WHEN DISCOUNTED)
                  if (currentPriceWithDiscount != null &&
                      currentPrice != null &&
                      currentPriceWithDiscount < currentPrice)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: CustomDirectionalityWidget(
                        child: Text(
                          PriceConverterHelper.convertPrice(
                            context,
                            currentPrice,
                          ),
                          style: poppinsMedium.copyWith(
                            fontSize: 15,
                            decoration: TextDecoration.lineThrough,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrandChip(BuildContext context) {
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);

    String brandName =
        product?.brand?.name ?? brandProvider.brandDetails?.name ?? '';

    String brandImage =
        product?.brand?.image ?? brandProvider.brandDetails?.imageUrl ?? '';
    if (brandImage.isNotEmpty && !brandImage.startsWith('http://') && !brandImage.startsWith('https://')) {
      final baseUrl = Provider.of<SplashProvider>(context, listen: false).baseUrls?.brandImageUrl;
      if (baseUrl != null && baseUrl.isNotEmpty) {
        brandImage = '$baseUrl/$brandImage';
      }
    }

    if (brandName.isEmpty) {
      return const SizedBox();
    }

    return _buildInfoChip(
      context: context,
      title: getTranslated('brand', context),
      value: brandName,
      image: brandImage,
      icon: Icons.workspace_premium_outlined,
    );
  }

  Widget _buildSellerChip(BuildContext context) {
    final sellerProvider = Provider.of<SellerProvider>(context, listen: false);

    String sellerName = '';
    String sellerImage = '';

    if (product?.seller?.name != null && product!.seller!.name!.trim().isNotEmpty) {
      sellerName = product!.seller!.name!;

      sellerImage = (product?.seller?.image != null && product!.seller!.image!.trim().isNotEmpty)
          ? product!.seller!.image!
          : (product?.seller?.logo != null && product!.seller!.logo!.trim().isNotEmpty)
              ? product!.seller!.logo!
              : (sellerProvider.sellerDetails?.logoUrl ?? '');
      if (sellerImage.isNotEmpty && !sellerImage.startsWith('http://') && !sellerImage.startsWith('https://')) {
        final baseUrl = Provider.of<SplashProvider>(context, listen: false).baseUrls?.sellerImageUrl;
        if (baseUrl != null && baseUrl.isNotEmpty) {
          sellerImage = '$baseUrl/$sellerImage';
        }
      }
    } else if (product?.addedBy == 'admin') {
      sellerName = getTranslated('in_house_shop', context);
    } else if (sellerProvider.sellerDetails?.name != null && sellerProvider.sellerDetails!.name!.trim().isNotEmpty) {
      sellerName = sellerProvider.sellerDetails!.name!;
      sellerImage = sellerProvider.sellerDetails?.logoUrl ?? '';
    }

    if (sellerName.isEmpty) {
      return const SizedBox();
    }

    return _buildInfoChip(
      context: context,
      title: getTranslated('seller', context),
      value: sellerName,
      image: sellerImage,
      icon: Icons.storefront_outlined,
    );
  }

  Widget _buildInfoChip({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    String? image,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.03),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image != null && image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomImageWidget(
                image: image,
                height: 36,
                width: 36,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: poppinsRegular.copyWith(
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 2),

              Text(value, style: poppinsSemiBold.copyWith(fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
