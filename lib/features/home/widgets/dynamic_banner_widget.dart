import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../common/widgets/custom_image_widget.dart';
import '../../../helper/banner_tap_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../splash/providers/splash_provider.dart';
import '../domain/models/banner_model.dart';
import '../providers/banner_provider.dart';

class DynamicBannerWidget extends StatelessWidget {
  final String section;
  final EdgeInsetsGeometry? padding;

  const DynamicBannerWidget({
    super.key,
    required this.section,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerProvider>(
      builder: (context, bannerProvider, _) {
        // إذا كانت البيانات لا تزال قيد التحميل لأول مرة
        if (bannerProvider.bannerList == null) {
          return _buildShimmer(context);
        }

        // جلب البانرات التابعة لهذا القسم تحديداً
        final banners = bannerProvider.getBannersForSection(section);

        // إذا لم توجد أي بانرات لهذا القسم، يختفي الويدجت تماماً دون ترك أي فراغ
        if (banners.isEmpty) {
          return const SizedBox.shrink();
        }

        // التجميع الذكي: تجميع البانرات المتتالية حسب نوع العرض لتمكين الدمج المتنوع في نفس القسم
        final groups = _groupBanners(banners);

        return Padding(
          padding: padding ??
              const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall,
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < groups.length; i++) ...[
                if (i > 0)
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                _renderGroup(context, groups[i]),
              ],
            ],
          ),
        );
      },
    );
  }

  /// تجميع البانرات بذكاء حسب نوع العرض
  List<_BannerGroup> _groupBanners(List<BannerModel> banners) {
    final List<_BannerGroup> groups = [];

    for (final banner in banners) {
      final type = banner.displayType ?? 'single';

      if (type == 'single') {
        // كل بانر مفرد يشكل عنصراً مستقلاً بذاته
        groups.add(_BannerGroup(displayType: 'single', items: [banner]));
      } else {
        // تجميع السلايدر أو الشبكة المتتالية معاً في مجموعة واحدة
        if (groups.isNotEmpty &&
            groups.last.displayType == type &&
            (type != 'grid_2x2' || groups.last.items.length < 4)) {
          groups.last.items.add(banner);
        } else {
          groups.add(_BannerGroup(displayType: type, items: [banner]));
        }
      }
    }

    return groups;
  }

  Widget _renderGroup(BuildContext context, _BannerGroup group) {
    // 1. شبكة 2×2
    if (group.displayType == 'grid_2x2') {
      return _buildGrid2x2(context, group.items);
    }

    // 2. سلايدر أفقي متحرك
    if (group.displayType == 'carousel_horizontal') {
      if (group.items.length == 1) {
        return _buildSingleBanner(context, group.items.first);
      }
      return _CarouselSectionWidget(
        banners: group.items,
        section: section,
      );
    }

    // 3. بانر مفرد ثابت
    return _buildSingleBanner(context, group.items.first);
  }

  /// بناء بانر مفرد ثابت
  Widget _buildSingleBanner(BuildContext context, BannerModel banner) {
    final Size size = MediaQuery.sizeOf(context);
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    // حساب الارتفاع المناسب حسب القسم ونوع الشاشة
    double bannerHeight;
    if (section == 'home_top') {
      bannerHeight = isDesktop
          ? 180.0
          : ResponsiveHelper.isTab(context)
              ? 140.0
              : (size.width * 0.25).clamp(90.0, 150.0).roundToDouble();
    } else {
      bannerHeight = isDesktop
          ? 180.0
          : (size.width * 0.45).clamp(130.0, 220.0).roundToDouble();
    }

    final baseUrl =
        Provider.of<SplashProvider>(context, listen: false).baseUrls?.bannerImageUrl ?? '';

    return Center(
      child: Container(
        width: isDesktop ? Dimensions.webScreenWidth : double.infinity,
        height: bannerHeight,
        margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          onTap: () => BannerTapHelper.onBannerTap(context, banner),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            child: CustomImageWidget(
              height: bannerHeight,
              width: double.infinity,
              placeholder: Images.placeHolder,
              image: '$baseUrl/${banner.image}',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  /// بناء شبكة 2×2 للبانرات
  Widget _buildGrid2x2(BuildContext context, List<BannerModel> banners) {
    final Size size = MediaQuery.sizeOf(context);
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final baseUrl =
        Provider.of<SplashProvider>(context, listen: false).baseUrls?.bannerImageUrl ?? '';

    // نأخذ حتى 4 بانرات
    final displayBanners = banners.take(4).toList();

    return Container(
      width: Dimensions.webScreenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? Dimensions.paddingSizeLarge
            : Dimensions.paddingSizeDefault,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double itemWidth = isDesktop
              ? (Dimensions.webScreenWidth - 40) / 2
              : (constraints.maxWidth - Dimensions.paddingSizeSmall) / 2;
          final double itemHeight = isDesktop
              ? 220.0
              : (size.width * 0.48).clamp(140.0, 220.0).roundToDouble();

          return Column(
            children: [
              // الصف الأول
              Row(
                children: [
                  Expanded(
                    child: _buildGridTile(
                      context,
                      displayBanners[0],
                      itemWidth,
                      itemHeight,
                      baseUrl,
                    ),
                  ),
                  if (displayBanners.length > 1) ...[
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: _buildGridTile(
                        context,
                        displayBanners[1],
                        itemWidth,
                        itemHeight,
                        baseUrl,
                      ),
                    ),
                  ],
                ],
              ),

              // الصف الثاني إن وجد
              if (displayBanners.length > 2) ...[
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridTile(
                        context,
                        displayBanners[2],
                        itemWidth,
                        itemHeight,
                        baseUrl,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: displayBanners.length > 3
                          ? _buildGridTile(
                              context,
                              displayBanners[3],
                              itemWidth,
                              itemHeight,
                              baseUrl,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildGridTile(
    BuildContext context,
    BannerModel banner,
    double width,
    double height,
    String baseUrl,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
      onTap: () => BannerTapHelper.onBannerTap(context, banner),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          child: CustomImageWidget(
            height: height,
            width: width,
            placeholder: Images.placeHolder,
            image: '$baseUrl/${banner.image}',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  /// تأثير الشيمر أثناء التحميل الأولي
  Widget _buildShimmer(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double shimmerHeight = section == 'home_top'
        ? (size.width * 0.25).clamp(80.0, 140.0)
        : (size.width * 0.45).clamp(120.0, 180.0);

    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        height: shimmerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}

/// ويدجت السلايدر المتحرك المستقل (StatefulWidget للحفاظ على حالة المؤشر الخاصة به)
class _CarouselSectionWidget extends StatefulWidget {
  final List<BannerModel> banners;
  final String section;

  const _CarouselSectionWidget({
    required this.banners,
    required this.section,
  });

  @override
  State<_CarouselSectionWidget> createState() => _CarouselSectionWidgetState();
}

class _CarouselSectionWidgetState extends State<_CarouselSectionWidget> {
  int _carouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final double carouselHeight = isDesktop
        ? 160.0
        : (size.width * 0.45).clamp(130.0, 200.0).roundToDouble();
    final baseUrl =
        Provider.of<SplashProvider>(context, listen: false).baseUrls?.bannerImageUrl ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: Dimensions.webScreenWidth,
          height: carouselHeight,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              height: carouselHeight,
              autoPlay: widget.banners.length > 1,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              enlargeCenterPage: isDesktop,
              viewportFraction: isDesktop ? 0.33 : 0.88,
              enlargeFactor: 0.15,
              enableInfiniteScroll: widget.banners.length > 1,
              onPageChanged: (index, _) {
                setState(() {
                  _carouselIndex = index;
                });
              },
            ),
            itemCount: widget.banners.length,
            itemBuilder: (context, index, _) {
              final banner = widget.banners[index];
              return InkWell(
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                onTap: () => BannerTapHelper.onBannerTap(context, banner),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                    child: CustomImageWidget(
                      height: carouselHeight,
                      width: double.infinity,
                      placeholder: Images.placeHolder,
                      image: '$baseUrl/${banner.image}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // مؤشر الصفحات (Dots Indicator)
        if (widget.banners.length > 1) ...[
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (index) {
              final isSelected = index == _carouselIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 5,
                width: isSelected ? 18 : 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// هيكل بيانات تجميع البانرات حسب نوع العرض
class _BannerGroup {
  final String displayType;
  final List<BannerModel> items;

  _BannerGroup({required this.displayType, required this.items});
}
