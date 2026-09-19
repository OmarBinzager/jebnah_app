import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/category/domain/models/category_model.dart';
import '../../../common/models/product_model.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../providers/banner_provider.dart';
import '../../../features/category/providers/category_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../common/widgets/custom_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class TopBannersWidget extends StatelessWidget {
  const TopBannersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    // تحديد الارتفاع المناسب حسب نوع الشاشة
    double getBannerHeight() {
      if (ResponsiveHelper.isDesktop(context)) {
        return 180; // ارتفاع مناسب للشاشات الكبيرة
      } else if (ResponsiveHelper.isTab(context)) {
        return 140; // ارتفاع مناسب للتابلت
      } else {
        return size.width * 0.25; // 25% من عرض الشاشة للهواتف
      }
    }

    return Consumer<BannerProvider>(
      builder: (context, bannerProvider, child) {
        // فلترة البيانات لعرض البانرات التي تحتوي على "home_top" فقط
        final topBanners = bannerProvider.bannerList?.where((banner) {
          if (banner.sections == null) return false;
          return banner.sections!.contains('home_top');
        }).toList();

        // إذا كانت البيانات لا تزال تُحمل، نعرض تأثير الشيمر
        if (bannerProvider.bannerList == null) {
          return const TopBannerShimmer();
        }

        // إذا اكتمل التحميل وكانت القائمة المفلترة فارغة، تختفي المساحة تماماً
        if (topBanners == null || topBanners.isEmpty) {
          return const SizedBox();
        }

        // طالما البانر ثابت، نأخذ العنصر الأول فقط من القائمة المفلترة
        final firstBanner = topBanners.first;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Center(
            child: Container(
              width: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.webScreenWidth
                  : double.infinity,
              height: getBannerHeight(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  Dimensions.radiusSizeDefault,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                hoverColor: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    Dimensions.radiusSizeDefault,
                  ),
                  child: CustomImageWidget(
                    height: getBannerHeight(),
                    width: double.infinity,
                    placeholder: Images.placeHolder,
                    image:
                        '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.bannerImageUrl}/${firstBanner.image}',
                    fit: BoxFit
                        .fill, // تغيير من BoxFit.fill إلى BoxFit.cover للحفاظ على نسبة العرض إلى الارتفاع
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TopBannerShimmer extends StatelessWidget {
  const TopBannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // تحديد ارتفاع الشيمر بنفس ارتفاع البانر الفعلي
    double getShimmerHeight() {
      final Size size = MediaQuery.sizeOf(context);
      if (ResponsiveHelper.isDesktop(context)) {
        return 180;
      } else if (ResponsiveHelper.isTab(context)) {
        return 140;
      } else {
        return size.width * 0.25;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: true,
        child: Container(
          width: double.infinity,
          height: getShimmerHeight(),
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          ),
        ),
      ),
    );
  }
}
