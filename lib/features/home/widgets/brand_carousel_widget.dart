import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../../helper/responsive_helper.dart';

import '../../../localization/language_constraints.dart';
import '../../brand/providers/brand_provider.dart';
import '../../splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BrandCarouselWidget extends StatelessWidget {
  const BrandCarouselWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Consumer<BrandProvider>(
      builder: (context, brandProvider, child) {
        return Column(
          children: [
            // عنوان القسم
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated('brands', context),
                    style: poppinsSemiBold.copyWith(
                      fontSize: ResponsiveHelper.isDesktop(context)
                          ? Dimensions.fontSizeLarge
                          : Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // RouteHelper.getAllBrandsRoute();
                    },
                    child: Text(
                      getTranslated('view_all', context),
                      style: poppinsMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: Dimensions.webScreenWidth,
              height: ResponsiveHelper.isDesktop(context)
                  ? 200
                  : size.width * 0.45,
              padding: ResponsiveHelper.isDesktop(context)
                  ? const EdgeInsets.only(
                      top: Dimensions.paddingSizeLarge,
                      bottom: Dimensions.paddingSizeSmall,
                    )
                  : null,
              child: brandProvider.brandList != null
                  ? brandProvider.brandList!.isNotEmpty
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              CarouselSlider.builder(
                                options: CarouselOptions(
                                  autoPlay: true,
                                  enlargeCenterPage: true,
                                  viewportFraction:
                                      ResponsiveHelper.isDesktop(context)
                                      ? 0.25
                                      : 0.8,
                                  enlargeFactor: 0.2,
                                  disableCenter: false,
                                  onPageChanged: (index, reason) {
                                    Provider.of<BrandProvider>(
                                      context,
                                      listen: false,
                                    ).setCurrentCarouselIndex(index);
                                  },
                                ),
                                itemCount: brandProvider.brandList!.isEmpty
                                    ? 1
                                    : brandProvider.brandList!.length,
                                itemBuilder: (context, index, _) {
                                  return InkWell(
                                    hoverColor: Colors.transparent,
                                    onTap: () {
                                      // RouteHelper.getBrandDetailsRoute(
                                      //   brandId: brandProvider.brandList![index].id.toString(),
                                      // );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context).cardColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 7,
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      10,
                                                    ),
                                                    topRight: Radius.circular(
                                                      10,
                                                    ),
                                                  ),
                                              child: CustomImageWidget(
                                                height:
                                                    ResponsiveHelper.isDesktop(
                                                      context,
                                                    )
                                                    ? 150
                                                    : size.width * 0.35,
                                                width: double.infinity,
                                                placeholder: Images.placeHolder,
                                                image:
                                                    '${Provider.of<SplashProvider>(context, listen: false).baseUrls?.brandImageUrl}/${brandProvider.brandList![index].image}',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                    vertical: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),
                                              child: Text(
                                                brandProvider
                                                        .brandList![index]
                                                        .name ??
                                                    '',
                                                style: poppinsMedium.copyWith(
                                                  fontSize:
                                                      ResponsiveHelper.isDesktop(
                                                        context,
                                                      )
                                                      ? Dimensions
                                                            .fontSizeDefault
                                                      : Dimensions
                                                            .fontSizeDefault,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              if (!ResponsiveHelper.isDesktop(context))
                                const Positioned(
                                  bottom: 5,
                                  left: 0,
                                  right: 0,
                                  child: BrandIndicatorView(),
                                ),
                            ],
                          )
                        : Center(
                            child: Text(
                              getTranslated('no_brand_available', context),
                            ),
                          )
                  : const BrandShimmer(),
            ),

            if (ResponsiveHelper.isDesktop(context))
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                ),
                child: BrandIndicatorView(),
              ),
          ],
        );
      },
    );
  }
}

class BrandShimmer extends StatelessWidget {
  const BrandShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).shadowColor,
        ),
      ),
    );
  }
}

class BrandIndicatorView extends StatelessWidget {
  const BrandIndicatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BrandProvider>(
      builder: (ctx, brandProvider, _) {
        return brandProvider.brandList == null
            ? const SizedBox()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: brandProvider.brandList!.map((brand) {
                  int index = brandProvider.brandList!.indexOf(brand);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 5,
                    width: 10,
                    decoration: BoxDecoration(
                      color: index == brandProvider.currentCarouselIndex
                          ? Theme.of(context).primaryColor
                          : Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSizeDefault,
                      ),
                    ),
                  );
                }).toList(),
              );
      },
    );
  }
}
