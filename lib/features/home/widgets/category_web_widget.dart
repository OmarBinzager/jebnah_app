import 'package:flutter/material.dart';

import '../../../features/home/widgets/category_shimmer_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/category/providers/category_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_image_widget.dart';

import 'package:provider/provider.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categoryList = categoryProvider.categoryList ?? [];

        final bool isDesktop = ResponsiveHelper.isDesktop(context);
        final double itemWidth = isDesktop ? 120 : 68;
        final double circleSize = isDesktop ? 100 : 54;
        final double iconSize = isDesktop ? 50 : 28;
        final double spacingBetween =
            isDesktop ? Dimensions.paddingSizeSmall : 4.0;
        final double marginRight =
            isDesktop ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeSmall;

        return categoryProvider.categoryList == null
            ? const CategoriesShimmerWidget()
            : (categoryList.isNotEmpty)
            ? Column(
                children: [
                  SizedBox(height: isDesktop ? 30 : 8),

                  // قائمة الفئات الأفقية مع إمكانية التمرير
                  SizedBox(
                    height: isDesktop ? 150 : 96,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop
                            ? Dimensions.paddingSizeDefault
                            : Dimensions.paddingSizeSmall,
                        vertical: isDesktop
                            ? Dimensions.paddingSizeSmall
                            : 2.0,
                      ),
                      physics: const BouncingScrollPhysics(),
                      // إضافة عنصر إضافي لعرض الكل
                      itemCount: categoryList.length + 1,
                      itemBuilder: (context, index) {
                        // إذا كان هذا هو العنصر الأخير (عرض الكل)
                        if (index == categoryList.length) {
                          return Container(
                            width: itemWidth,
                            margin: EdgeInsets.only(
                              right: marginRight,
                            ),
                            child: InkWell(
                              onTap: () {
                                RouteHelper.getAllCategoryScreen();
                              },
                              child: Column(
                                children: [
                                  // أيقونة عرض الكل
                                  Container(
                                    height: circleSize,
                                    width: circleSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).primaryColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.view_list_rounded,
                                      color: Colors.white,
                                      size: iconSize,
                                    ),
                                  ),

                                  SizedBox(
                                    height: spacingBetween,
                                  ),

                                  // نص عرض الكل
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          Dimensions.paddingSizeExtraSmall,
                                    ),
                                    child: Text(
                                      getTranslated('view_all', context),
                                      style: poppinsMedium.copyWith(
                                        fontSize: isDesktop
                                            ? Dimensions.fontSizeDefault
                                            : Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context).primaryColor,
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

                        // عرض الفئات العادية
                        final category = categoryList[index];
                        return Container(
                          width: itemWidth,
                          margin: EdgeInsets.only(
                            right: marginRight,
                          ),
                          child: InkWell(
                            onTap: () {
                              categoryProvider.onChangeSelectIndex(
                                -1,
                                notify: false,
                              );
                              RouteHelper.getCategoryProductsRoute(
                                categoryId: '${category.id}',
                                categoryName: '${category.name}',
                              );
                            },
                            child: Column(
                              children: [
                                // صورة الفئة
                                Container(
                                  height: circleSize,
                                  width: circleSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).cardColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: CustomImageWidget(
                                      image:
                                          '${splashProvider.baseUrls?.categoryImageUrl}/${category.image}',
                                      fit: BoxFit.cover,
                                      height: circleSize,
                                      width: circleSize,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: spacingBetween,
                                ),

                                // اسم الفئة
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: Text(
                                    category.name ?? '',
                                    style: poppinsRegular.copyWith(
                                      fontSize: isDesktop
                                          ? Dimensions.fontSizeSmall
                                          : Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
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
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox();
      },
    );
  }
}
