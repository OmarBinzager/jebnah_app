import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../common/models/product_model.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../common/providers/product_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../common/widgets/wish_button_widget.dart';
import 'package:provider/provider.dart';

class ProductImageWidget extends StatelessWidget {
  final Product? productModel;
  const ProductImageWidget({super.key, required this.productModel});

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            InkWell(
              onTap: () => RouteHelper.getProductImagesRoute(
                productModel!.name,
                jsonEncode(productModel!.image),
                splashProvider.baseUrls?.productImageUrl ?? '',
              ),
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, _) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: ResponsiveHelper.isDesktop(context)
                        ? 350
                        : MediaQuery.of(context).size.height * 0.4,
                    child: PageView.builder(
                      itemCount: productModel?.image?.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CustomImageWidget(
                              image:
                                  '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${productModel!.image![cartProvider.productSelect]}',
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                      onPageChanged: (index) {
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).onSelectProductStatus(index, true);
                        Provider.of<ProductProvider>(
                          context,
                          listen: false,
                        ).setImageSliderSelectedIndex(index);
                      },
                    ),
                  );
                },
              ),
            ),

            Positioned(
              top: 26,
              right: 26,
              child: WishButtonWidget(
                product: productModel,
                edgeInset: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
