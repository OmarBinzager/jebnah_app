import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/models/product_model.dart';
import '../../../common/providers/product_provider.dart';

import '../../../common/widgets/custom_directionality_widget.dart';
import '../../../common/widgets/custom_image_widget.dart';

import '../../../helper/price_converter_helper.dart';
import '../../../helper/responsive_helper.dart';

import '../../../localization/language_constraints.dart';

import '../../../utill/color_resources.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';

import '../../brand/providers/brand_provider.dart';
import '../../home/providers/seller_provider.dart';

class ProductTitleWidget extends StatelessWidget {
  final Product? product;
  final int? stock;
  final int? cartIndex;

  const ProductTitleWidget({
    super.key,
    required this.product,
    required this.stock,
    required this.cartIndex,
  });

  @override
  Widget build(BuildContext context) {
    double? startingPrice;
    double? startingPriceWithDiscount;
    double? endingPrice;
    double? endingPriceWithDiscount;

    if (product!.variations!.isNotEmpty) {
      List<double?> priceList = [];

      for (var variation in product!.variations!) {
        priceList.add(variation.price);
      }

      priceList.sort((a, b) => a!.compareTo(b!));

      startingPrice = priceList.first;

      if (priceList.first! < priceList.last!) {
        endingPrice = priceList.last;
      }
    } else {
      startingPrice = product!.price;
    }

    startingPriceWithDiscount = PriceConverterHelper.convertWithDiscount(
      startingPrice,
      product!.discount,
      product!.discountType,
    );

    if (endingPrice != null) {
      endingPriceWithDiscount = PriceConverterHelper.convertWithDiscount(
        endingPrice,
        product!.discount,
        product!.discountType,
      );
    }

    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
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
                children: [_buildBrandChip(context)],
              ),

              const SizedBox(height: 18),

              /// PRICE
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /// DISCOUNT PRICE
                  CustomDirectionalityWidget(
                    child: Text(
                      '${PriceConverterHelper.convertPrice(context, startingPriceWithDiscount)}'
                      '${endingPriceWithDiscount != null ? ' - ${PriceConverterHelper.convertPrice(context, endingPriceWithDiscount)}' : ''}',
                      style: poppinsBold.copyWith(
                        fontSize: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// ORIGINAL PRICE
                  if (startingPriceWithDiscount! < startingPrice!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: CustomDirectionalityWidget(
                        child: Text(
                          '${PriceConverterHelper.convertPrice(context, startingPrice)}',
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

    bool isAdmin = product?.addedBy == 'admin';

    String sellerName = '';

    String sellerImage = '';

    if (isAdmin) {
      sellerName = getTranslated('in_house_shop', context);
    } else if (product?.seller?.name != null) {
      sellerName = product!.seller!.name ?? '';

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
