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

        return categoryProvider.categoryList == null
            ? const CategoriesShimmerWidget()
            : (categoryList.isNotEmpty)
            ? Column(
                children: [
                  const SizedBox(height: 30),

                  // قائمة الفئات الأفقية مع إمكانية التمرير
                  SizedBox(
                    height: ResponsiveHelper.isDesktop(context) ? 150 : 130,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      physics: const BouncingScrollPhysics(),
                      // إضافة عنصر إضافي لعرض الكل
                      itemCount: categoryList.length + 1,
                      itemBuilder: (context, index) {
                        // إذا كان هذا هو العنصر الأخير (عرض الكل)
                        if (index == categoryList.length) {
                          return Container(
                            width: ResponsiveHelper.isDesktop(context)
                                ? 120
                                : 90,
                            margin: const EdgeInsets.only(
                              right: Dimensions.paddingSizeDefault,
                            ),
                            child: InkWell(
                              onTap: () {
                                if (ResponsiveHelper.isWeb()) {
                                  RouteHelper.getAllCategoryScreen();
                                } else {
                                  RouteHelper.getAllCategoryScreen();
                                }
                              },
                              child: Column(
                                children: [
                                  // أيقونة عرض الكل
                                  Container(
                                    height: ResponsiveHelper.isDesktop(context)
                                        ? 100
                                        : 70,
                                    width: ResponsiveHelper.isDesktop(context)
                                        ? 100
                                        : 70,
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
                                      size: ResponsiveHelper.isDesktop(context)
                                          ? 50
                                          : 35,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
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
                                        fontSize: Dimensions.fontSizeDefault,
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
                          width: ResponsiveHelper.isDesktop(context) ? 120 : 90,
                          margin: const EdgeInsets.only(
                            right: Dimensions.paddingSizeDefault,
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
                                  height: ResponsiveHelper.isDesktop(context)
                                      ? 100
                                      : 70,
                                  width: ResponsiveHelper.isDesktop(context)
                                      ? 100
                                      : 70,
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
                                      height:
                                          ResponsiveHelper.isDesktop(context)
                                          ? 100
                                          : 70,
                                      width: ResponsiveHelper.isDesktop(context)
                                          ? 100
                                          : 70,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
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
                                      fontSize: Dimensions.fontSizeSmall,
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
