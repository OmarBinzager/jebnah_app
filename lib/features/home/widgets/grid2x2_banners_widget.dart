import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/category/domain/models/category_model.dart';
import '../../../common/models/product_model.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';

import '../domain/models/banner_model.dart';
import '../providers/banner_provider.dart';
import '../../../features/category/providers/category_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../common/widgets/custom_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class Grid2x2BannersWidget extends StatelessWidget {
  const Grid2x2BannersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Consumer<BannerProvider>(
      builder: (context, bannerProvider, child) {
        // فلترة البيانات لعرض البانرات التي تحتوي على "grid_2x2" فقط
        final gridBanners = bannerProvider.bannerList?.where((banner) {
          if (banner.displayType == null) return false;
          return banner.displayType!.contains('grid_2x2');
        }).toList();

        // إذا كانت البيانات لا تزال تُحمل، نعرض تأثير الشيمر
        if (bannerProvider.bannerList == null) {
          return const Grid2x2Shimmer();
        }

        // إذا اكتمل التحميل وكانت القائمة المفلترة فارغة، تختفي المساحة تماماً
        if (gridBanners == null || gridBanners.isEmpty) {
          return const SizedBox();
        }

        // نأخذ أول 4 بانرات فقط للشبكة 2×2
        final List<BannerModel?> displayBanners = gridBanners.take(4).toList();

        // تعبئة البانرات الناقصة (إذا كان العدد أقل من 4)
        while (displayBanners.length < 4) {
          displayBanners.add(null);
        }

        return Container(
          width: Dimensions.webScreenWidth,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.isDesktop(context)
                ? Dimensions.paddingSizeLarge
                : Dimensions.paddingSizeDefault,
            vertical: ResponsiveHelper.isDesktop(context)
                ? Dimensions.paddingSizeLarge
                : Dimensions.paddingSizeSmall,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // حساب حجم كل عنصر
              final double itemWidth = ResponsiveHelper.isDesktop(context)
                  ? (Dimensions.webScreenWidth - 40) / 2
                  : (constraints.maxWidth - 12) / 2;

              // زيادة الطول قليلاً
              final double itemHeight = ResponsiveHelper.isDesktop(context)
                  ? 240
                  : size.width * 0.55;

              return Column(
                children: [
                  // الصف الأول
                  Row(
                    children: [
                      Expanded(
                        child: _buildGridItem(
                          context,
                          displayBanners[0],
                          itemWidth,
                          itemHeight,
                          bannerProvider,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: _buildGridItem(
                          context,
                          displayBanners[1],
                          itemWidth,
                          itemHeight,
                          bannerProvider,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // الصف الثاني
                  Row(
                    children: [
                      Expanded(
                        child: _buildGridItem(
                          context,
                          displayBanners[2],
                          itemWidth,
                          itemHeight,
                          bannerProvider,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: _buildGridItem(
                          context,
                          displayBanners[3],
                          itemWidth,
                          itemHeight,
                          bannerProvider,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    BannerModel? banner,
    double width,
    double height,
    BannerProvider bannerProvider,
  ) {
    // إذا كان البانر غير موجود (للتعبئة)
    if (banner == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          color: Theme.of(context).shadowColor.withOpacity(0.1),
        ),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 40,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      );
    }

    return InkWell(
      hoverColor: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          // تم إزالة الظل تماماً
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          child: CustomImageWidget(
            height: height,
            width: width,
            placeholder: Images.placeHolder,
            image:
                '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}/${banner.image}',
            fit: BoxFit.cover, // الصورة تغطي المساحة بالكامل
          ),
        ),
      ),
    );
  }
}

// تأثير الشيمر أثناء تحميل الشبكة 2×2
class Grid2x2Shimmer extends StatelessWidget {
  const Grid2x2Shimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Container(
        width: Dimensions.webScreenWidth,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isDesktop(context)
              ? Dimensions.paddingSizeLarge
              : Dimensions.paddingSizeDefault,
          vertical: ResponsiveHelper.isDesktop(context)
              ? Dimensions.paddingSizeLarge
              : Dimensions.paddingSizeSmall,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شبكة الشيمر 2×2
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: ResponsiveHelper.isDesktop(context)
                            ? 240
                            : size.width * 0.55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSizeDefault,
                          ),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Container(
                        height: ResponsiveHelper.isDesktop(context)
                            ? 240
                            : size.width * 0.55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSizeDefault,
                          ),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: ResponsiveHelper.isDesktop(context)
                            ? 240
                            : size.width * 0.55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSizeDefault,
                          ),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Container(
                        height: ResponsiveHelper.isDesktop(context)
                            ? 240
                            : size.width * 0.55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSizeDefault,
                          ),
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
