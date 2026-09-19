import 'package:flutter/material.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/category/providers/category_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_image_widget.dart';
import 'package:provider/provider.dart';

class CategoryGrid2x2Widget extends StatelessWidget {
  const CategoryGrid2x2Widget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categoryList = categoryProvider.categoryList ?? [];

        if (categoryProvider.categoryList == null) {
          return const CategoryGrid2x2Shimmer();
        }

        if (categoryList.isEmpty) {
          return const SizedBox();
        }

        // نأخذ أول 6 فئات فقط للشبكة
        final displayCategories = categoryList.take(6).toList();

        return Container(
          width: Dimensions.webScreenWidth,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.isDesktop(context)
                ? Dimensions.paddingSizeLarge
                : Dimensions.paddingSizeDefault,
            vertical: ResponsiveHelper.isDesktop(context)
                ? Dimensions.paddingSizeLarge
                : Dimensions.paddingSizeDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // عنوان القسم - في المنتصف
              Padding(
                padding: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeDefault,
                ),
                child: Center(
                  child: Text(
                    getTranslated('shop_with_best_categories', context),
                    style: poppinsSemiBold.copyWith(
                      fontSize: ResponsiveHelper.isDesktop(context)
                          ? Dimensions.fontSizeExtraLarge
                          : Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // الشبكة
              LayoutBuilder(
                builder: (context, constraints) {
                  // حساب حجم كل عنصر بناءً على عرض الشاشة
                  final double itemWidth = ResponsiveHelper.isDesktop(context)
                      ? (Dimensions.webScreenWidth - 40) / 2
                      : (constraints.maxWidth - 12) / 2;

                  final double itemHeight = ResponsiveHelper.isDesktop(context)
                      ? 200
                      : size.width * 0.45;

                  // ترتيب الفئات في صفوف (كل صف يحتوي على فئتين)
                  List<Widget> rows = [];
                  for (int i = 0; i < displayCategories.length; i += 2) {
                    rows.add(
                      Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildCategoryItem(
                                  context,
                                  displayCategories[i],
                                  itemWidth,
                                  itemHeight,
                                  splashProvider,
                                  size,
                                ),
                              ),
                              if (i + 1 < displayCategories.length) ...[
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),
                                Expanded(
                                  child: _buildCategoryItem(
                                    context,
                                    displayCategories[i + 1],
                                    itemWidth,
                                    itemHeight,
                                    splashProvider,
                                    size,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (i + 2 < displayCategories.length)
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                        ],
                      ),
                    );
                  }

                  return Column(children: rows);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    dynamic category,
    double width,
    double height,
    SplashProvider splashProvider,
    dynamic size,
  ) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        final categoryProvider = Provider.of<CategoryProvider>(
          context,
          listen: false,
        );
        categoryProvider.onChangeSelectIndex(-1, notify: false);
        RouteHelper.getCategoryProductsRoute(
          categoryId: '${category.id}',
          categoryName: '${category.name}',
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // تغيير من center إلى start
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // مساحة مرنة في الأعلى لدفع المحتوى للأسفل قليلاً
            const Spacer(),

            // صورة الفئة
            Container(
              height: ResponsiveHelper.isDesktop(context)
                  ? 110
                  : size.width * 0.25,
              width: ResponsiveHelper.isDesktop(context)
                  ? 110
                  : size.width * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  image:
                      '${splashProvider.baseUrls?.categoryImageUrl}/${category.image}',
                  fit: BoxFit.contain,
                  height: ResponsiveHelper.isDesktop(context)
                      ? 110
                      : size.width * 0.25,
                  width: ResponsiveHelper.isDesktop(context)
                      ? 110
                      : size.width * 0.25,
                  placeholder: Images.placeHolder,
                ),
              ),
            ),

            // مسافة صغيرة بين الصورة والنص
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // اسم الفئة - يمتد من الطرف إلى الطرف
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(Dimensions.radiusSizeDefault),
                  bottomRight: Radius.circular(Dimensions.radiusSizeDefault),
                ),
              ),
              child: Text(
                category.name ?? '',
                style: poppinsMedium.copyWith(
                  fontSize: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeDefault
                      : Dimensions.fontSizeDefault,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// تأثير الشيمر أثناء تحميل شبكة الفئات
class CategoryGrid2x2Shimmer extends StatelessWidget {
  const CategoryGrid2x2Shimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Container(
      width: Dimensions.webScreenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeLarge
            : Dimensions.paddingSizeDefault,
        vertical: ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeLarge
            : Dimensions.paddingSizeDefault,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // عنوان الشيمر في المنتصف
          Center(
            child: Container(
              width: 200,
              height: 24,
              margin: const EdgeInsets.only(
                bottom: Dimensions.paddingSizeDefault,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                color: Colors.grey.shade300,
              ),
            ),
          ),

          // شبكة الشيمر
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildShimmerItem(context, size)),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: _buildShimmerItem(context, size)),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                children: [
                  Expanded(child: _buildShimmerItem(context, size)),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: _buildShimmerItem(context, size)),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                children: [
                  Expanded(child: _buildShimmerItem(context, size)),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: _buildShimmerItem(context, size)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerItem(BuildContext context, Size size) {
    return Container(
      height: ResponsiveHelper.isDesktop(context) ? 200 : size.width * 0.45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Spacer(),
          Container(
            height: ResponsiveHelper.isDesktop(context)
                ? 100
                : size.width * 0.22,
            width: ResponsiveHelper.isDesktop(context)
                ? 100
                : size.width * 0.22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Container(width: double.infinity, height: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
