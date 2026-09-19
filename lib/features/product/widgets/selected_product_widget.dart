import 'package:flutter/material.dart';
import '../../../common/models/product_model.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../common/providers/product_provider.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/responsive_helper.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/dimensions.dart';
import 'package:provider/provider.dart';

class SelectedImageWidget extends StatelessWidget {
  final Product? productModel;

  const SelectedImageWidget({super.key, this.productModel});

  @override
  Widget build(BuildContext context) {
    final CartProvider cartProvider = Provider.of<CartProvider>(
      context,
      listen: false,
    );
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return ListView.builder(
          itemCount: productProvider.product?.image?.length,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.isDesktop(context)
                ? Dimensions.paddingSizeSmall
                : Dimensions.paddingSizeLarge,
          ),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(
                right: Dimensions.paddingSizeSmall,
              ),
              child: InkWell(
                onTap: () {
                  cartProvider.onSelectProductStatus(index, true);
                },
                child: Container(
                  padding: EdgeInsets.all(2), // Border width
                  decoration: BoxDecoration(
                    gradient: cartProvider.productSelect == index
                        ? LinearGradient(
                            colors: [Color(0xff01684B), Color(0xff02CE95)],
                          )
                        : null,
                    border: cartProvider.productSelect != index
                        ? Border.all(
                            color: ColorResources.getGreyColor(context),
                            width: 1,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(
                      cartProvider.productSelect == index ? 3 : 2,
                    ),
                    width: ResponsiveHelper.isDesktop(context) ? 70 : 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSizeTen,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSizeDefault,
                      ),
                      child: CustomImageWidget(
                        image:
                            '${splashProvider.baseUrls?.productImageUrl}/${productProvider.product?.image?[index]}',
                        width: ResponsiveHelper.isDesktop(context) ? 70 : 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
