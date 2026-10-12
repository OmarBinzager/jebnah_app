import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../common/widgets/main_app_bar_widget.dart';
import '../../../common/widgets/no_data_widget.dart';
import '../../../features/category/domain/models/category_model.dart';
import '../../../features/category/providers/category_provider.dart';
import '../../../features/category/widgets/category_item_widget.dart';
import '../../../features/category/widgets/sub_category_shimmer_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final categoryProvider = Provider.of<CategoryProvider>(
          context,
          listen: false,
        );
        if (categoryProvider.categoryList != null &&
            categoryProvider.categoryList!.isNotEmpty) {
          _load();
        } else {
          categoryProvider.getCategoryList(context, true).then((list) {
            if (list != null && mounted) {
              _load();
            }
          });
        }
      }
    });
  }

  Future<void> _load() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    int currentIndex = categoryProvider.categoryIndex;
    if (categoryProvider.categoryList?.isNotEmpty ?? false) {
      if (currentIndex < 0 ||
          currentIndex >= categoryProvider.categoryList!.length) {
        currentIndex = 0;
        categoryProvider.onChangeCategoryIndex(0, notify: false);
      }
      categoryProvider.getSubCategoryList(
        context,
        categoryProvider.categoryList![currentIndex].id.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: (ResponsiveHelper.isDesktop(context) || kIsWeb)
            ? const MainAppBarWidget()
            : null,
        body: Center(
          child: SizedBox(
            width: Dimensions.webScreenWidth,
            child: Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                return categoryProvider.categoryList == null
                    ? Center(
                        child: CustomLoaderWidget(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : categoryProvider.categoryList?.isNotEmpty ?? false
                    ? Row(
                        children: [
                          Container(
                            width: 120,
                            margin: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                            height: double.maxFinite,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.02),
                            ),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: categoryProvider.categoryList!.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              itemBuilder: (context, index) {
                                CategoryModel category =
                                    categoryProvider.categoryList![index];
                                return InkWell(
                                  onTap: () {
                                    categoryProvider.onChangeCategoryIndex(
                                      index,
                                    );
                                    categoryProvider.getSubCategoryList(
                                      context,
                                      category.id.toString(),
                                    );
                                  },
                                  child: CategoryItemWidget(
                                    title: category.name,
                                    icon: category.image,
                                    isSelected:
                                        categoryProvider.categoryIndex == index,
                                  ),
                                );
                              },
                            ),
                          ),

                          categoryProvider.subCategoryList != null
                              ? Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeSmall,
                                    ),
                                    itemCount:
                                        categoryProvider
                                            .subCategoryList!
                                            .length +
                                        1,
                                    itemBuilder: (context, index) {
                                      if (index == 0) {
                                        return ListTile(
                                          onTap: () {
                                            categoryProvider
                                                .onChangeSelectIndex(-1);
                                            RouteHelper.getCategoryProductsRoute(
                                              categoryId:
                                                  '${categoryProvider.categoryList![categoryProvider.categoryIndex].id}',
                                              categoryName: categoryProvider
                                                  .categoryList![categoryProvider
                                                      .categoryIndex]
                                                  .name,
                                            );
                                          },
                                          title: Text(
                                            getTranslated('all', context),
                                          ),
                                          trailing: const Icon(
                                            Icons.keyboard_arrow_down_sharp,
                                          ),
                                        );
                                      }
                                      return ListTile(
                                        onTap: () {
                                          categoryProvider.onChangeSelectIndex(
                                            index - 1,
                                          );
                                          RouteHelper.getCategoryProductsRoute(
                                            categoryId:
                                                '${categoryProvider.categoryList![categoryProvider.categoryIndex].id}',
                                            categoryName: categoryProvider
                                                .categoryList![categoryProvider
                                                    .categoryIndex]
                                                .name,
                                          );
                                        },
                                        title: Text(
                                          categoryProvider
                                              .subCategoryList![index - 1]
                                              .name!,
                                          style: poppinsMedium.copyWith(
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color
                                                ?.withValues(alpha: 0.6),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: const Icon(
                                          Icons.keyboard_arrow_down_sharp,
                                        ),
                                      );
                                    },
                                    separatorBuilder: (ctx, idx) => Divider(
                                      color: Theme.of(
                                        context,
                                      ).hintColor.withValues(alpha: 0.1),
                                    ),
                                  ),
                                )
                              : const Expanded(
                                  child: SubCategoriesShimmerWidget(),
                                ),
                        ],
                      )
                    : NoDataWidget(
                        title: getTranslated('category_not_found', context),
                      );
              },
            ),
          ),
        ),
      ),
    );
  }
}
