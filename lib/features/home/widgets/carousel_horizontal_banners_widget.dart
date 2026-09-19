import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/category/domain/models/category_model.dart';
import '../../../common/models/product_model.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';

import '../providers/banner_provider.dart';
import '../../../features/category/providers/category_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../common/widgets/custom_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CarouselHorizontalBannersWidget extends StatelessWidget {
  const CarouselHorizontalBannersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Consumer<BannerProvider>(
      builder: (context, bannerProvider, child) {
        // فلترة البيانات لعرض البانرات التي تحتوي على "carousel_horizontal" فقط
        final carouselBanners = bannerProvider.bannerList?.where((banner) {
          if (banner.displayType == null) return false;
          return banner.displayType!.contains('carousel_horizontal');
        }).toList();

        // إذا كانت البيانات لا تزال تُحمل، نعرض تأثير الشيمر
        if (bannerProvider.bannerList == null) {
          return const CarouselHorizontalShimmer();
        }

        // إذا اكتمل التحميل وكانت القائمة المفلترة فارغة، تختفي المساحة تماماً
        if (carouselBanners == null || carouselBanners.isEmpty) {
          return const SizedBox();
        }

        return Column(
          children: [
            Container(
              width: Dimensions.webScreenWidth,
              height: ResponsiveHelper.isDesktop(context)
                  ? 180
                  : size.width * 0.45,
              padding: ResponsiveHelper.isDesktop(context)
                  ? const EdgeInsets.only(
                      top: Dimensions.paddingSizeLarge,
                      bottom: Dimensions.paddingSizeSmall,
                    )
                  : const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                    ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      enlargeCenterPage: ResponsiveHelper.isDesktop(context)
                          ? true
                          : false,
                      viewportFraction: ResponsiveHelper.isDesktop(context)
                          ? 0.33
                          : 0.85,
                      enlargeFactor: 0.2,
                      disableCenter: false,
                      onPageChanged: (index, reason) {
                        Provider.of<BannerProvider>(
                          context,
                          listen: false,
                        ).setCurrentCarouselIndex(index);
                      },
                    ),
                    itemCount: carouselBanners.length,
                    itemBuilder: (context, index, _) {
                      final banner = carouselBanners[index];
                      return InkWell(
                        hoverColor: Colors.transparent,
                        onTap: () async {
                          // معالجة الضغط على البانر
                          if (banner.externalLink != null &&
                              banner.externalLink!.isNotEmpty) {
                            final Uri url = Uri.parse(banner.externalLink!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          } else if (banner.productId != null) {
                            Product? product;
                            for (Product prod in bannerProvider.productList) {
                              if (prod.id == banner.productId) {
                                product = prod;
                                break;
                              }
                            }
                            if (product != null) {
                              RouteHelper.getProductDetailsRoute(
                                productId: product.id,
                              );
                            }
                          } else if (banner.categoryId != null) {
                            CategoryModel? category;
                            for (CategoryModel categoryModel
                                in Provider.of<CategoryProvider>(
                                  context,
                                  listen: false,
                                ).categoryList!) {
                              if (categoryModel.id == banner.categoryId) {
                                category = categoryModel;
                                break;
                              }
                            }
                            if (category != null) {
                              RouteHelper.getCategoryProductsRoute(
                                categoryId: '${category.id}',
                              );
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSizeDefault,
                            ),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSizeDefault,
                            ),
                            child: CustomImageWidget(
                              height: ResponsiveHelper.isDesktop(context)
                                  ? 180
                                  : size.width * 0.45,
                              width: ResponsiveHelper.isDesktop(context)
                                  ? 400
                                  : size.width,
                              placeholder: Images.placeHolder,
                              image:
                                  '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}/${banner.image}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // مؤشرات التمرير (للجوال فقط)
                  if (!ResponsiveHelper.isDesktop(context))
                    Positioned(
                      bottom: 5,
                      left: 0,
                      right: 0,
                      child: CarouselHorizontalIndicator(
                        itemCount: carouselBanners.length,
                      ),
                    ),
                ],
              ),
            ),

            // مؤشرات التمرير (للديسكتوب)
            if (ResponsiveHelper.isDesktop(context))
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                ),
                child: CarouselHorizontalIndicator(),
              ),
          ],
        );
      },
    );
  }
}

// مؤشرات التمرير لكاروسيل البانرات الأفقية
class CarouselHorizontalIndicator extends StatelessWidget {
  final int? itemCount;

  const CarouselHorizontalIndicator({super.key, this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (ctx, bannerProvider, _) {
        // إذا كان itemCount محدداً (للجوال) نستخدمه، وإلا نأخذه من الـ provider
        final banners = bannerProvider.bannerList?.where((banner) {
          if (banner.sections == null) return false;
          return banner.sections!.contains('carousel_horizontal');
        }).toList();

        final totalCount = itemCount ?? banners?.length ?? 0;

        if (totalCount == 0) {
          return const SizedBox();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalCount, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: index == bannerProvider.currentCarouselIndex ? 20 : 6,
              decoration: BoxDecoration(
                color: index == bannerProvider.currentCarouselIndex
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(
                  Dimensions.radiusSizeDefault,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// تأثير الشيمر أثناء تحميل الكاروسيل الأفقي
class CarouselHorizontalShimmer extends StatelessWidget {
  const CarouselHorizontalShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: SizedBox(
        height: ResponsiveHelper.isDesktop(context) ? 180 : size.width * 0.45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: ResponsiveHelper.isDesktop(context)
                  ? 350
                  : size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  Dimensions.radiusSizeDefault,
                ),
                color: Theme.of(context).shadowColor,
              ),
            );
          },
        ),
      ),
    );
  }
}
