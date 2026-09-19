import 'package:flutter/material.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/widgets/custom_app_bar_widget.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/no_data_widget.dart';
import '../../../common/widgets/paginated_list_widget.dart';
import '../../../common/widgets/product_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../common/widgets/web_product_shimmer_widget.dart';
import '../../../features/category/providers/category_provider.dart';
import '../../../features/product/widgets/category_cart_title_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CategoryProductScreen extends StatefulWidget {
  final String categoryId;
  final String? categoryName;
  const CategoryProductScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  State<CategoryProductScreen> createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends State<CategoryProductScreen> {
  final ScrollController scrollController = ScrollController();

  void _loadData(BuildContext context) async {
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    if (categoryProvider.selectedCategoryIndex == -1) {
      categoryProvider.getCategory(int.tryParse(widget.categoryId), context);

      categoryProvider.getSubCategoryList(context, widget.categoryId);

      categoryProvider.initCategoryProductList(widget.categoryId, 1);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _loadData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    String? appBarText = '';
    if (widget.categoryName != null && widget.categoryName != 'null') {
      appBarText = widget.categoryName;
    }
    categoryProvider.initializeAllSortBy(context);

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar:
            (ResponsiveHelper.isDesktop(context)
                    ? const PreferredSize(
                        preferredSize: Size.fromHeight(120),
                        child: WebAppBarWidget(),
                      )
                    : CustomAppBarWidget(
                        title: appBarText,
                        isCenter: false,
                        isElevation: true,
                        fromCategory: true,
                      ))
                as PreferredSizeWidget?,
        body: Consumer<CategoryProvider>(
          builder: (context, productProvider, child) {
            return Column(
              crossAxisAlignment: ResponsiveHelper.isDesktop(context)
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 70,
                  width: Dimensions.webScreenWidth,
                  child: Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      return categoryProvider.subCategoryList != null
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 15),
                              height: 32,
                              child: SizedBox(
                                width: ResponsiveHelper.isDesktop(context)
                                    ? 1170
                                    : MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: Dimensions
                                                    .paddingSizeDefault,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  categoryProvider
                                                      .onChangeSelectIndex(-1);
                                                  productProvider
                                                      .initCategoryProductList(
                                                        widget.categoryId,
                                                        1,
                                                      );
                                                },
                                                hoverColor: Colors.transparent,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeLarge,
                                                        vertical: Dimensions
                                                            .paddingSizeExtraSmall,
                                                      ),
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets.only(
                                                    right: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        categoryProvider
                                                                .selectedCategoryIndex ==
                                                            -1
                                                        ? Theme.of(
                                                            context,
                                                          ).primaryColor
                                                        : ColorResources.getGreyColor(
                                                            context,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          7,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    getTranslated(
                                                      'all',
                                                      context,
                                                    ),
                                                    style: poppinsRegular.copyWith(
                                                      color:
                                                          categoryProvider
                                                                  .selectedCategoryIndex ==
                                                              -1
                                                          ? Theme.of(
                                                              context,
                                                            ).canvasColor
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: categoryProvider
                                                  .subCategoryList!
                                                  .length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (BuildContext context, int index) {
                                                return InkWell(
                                                  onTap: () {
                                                    categoryProvider
                                                        .onChangeSelectIndex(
                                                          index,
                                                        );

                                                    productProvider
                                                        .initCategoryProductList(
                                                          '${categoryProvider.subCategoryList![index].id}',
                                                          1,
                                                        );
                                                  },
                                                  hoverColor:
                                                      Colors.transparent,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeLarge,
                                                          vertical: Dimensions
                                                              .paddingSizeExtraSmall,
                                                        ),
                                                    alignment: Alignment.center,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          categoryProvider
                                                                  .selectedCategoryIndex ==
                                                              index
                                                          ? Theme.of(
                                                              context,
                                                            ).primaryColor
                                                          : ColorResources.getGreyColor(
                                                              context,
                                                            ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            7,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      categoryProvider
                                                              .subCategoryList?[index]
                                                              .name ??
                                                          '',
                                                      style: poppinsRegular
                                                          .copyWith(
                                                            color:
                                                                categoryProvider
                                                                        .selectedCategoryIndex ==
                                                                    index
                                                                ? Theme.of(
                                                                    context,
                                                                  ).canvasColor
                                                                : Colors.black,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // if(ResponsiveHelper.isDesktop(context)) Spacer(),
                                    if (ResponsiveHelper.isDesktop(context))
                                      PopupMenuButton(
                                        elevation: 20,
                                        enabled: true,
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                        ),
                                        onSelected: (dynamic value) {
                                          int index = categoryProvider.allSortBy
                                              .indexOf(value);

                                          categoryProvider.sortCategoryProduct(
                                            index,
                                          );
                                        },

                                        itemBuilder: (context) {
                                          return categoryProvider.allSortBy.map(
                                            (choice) {
                                              return PopupMenuItem(
                                                value: choice,
                                                child: Text(
                                                  getTranslated(
                                                    choice,
                                                    context,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).toList();
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            )
                          : const _SubcategoryTitleShimmer();
                    },
                  ),
                ),

                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child:
                            (productProvider.subCategoryProductList?.products ??
                                    [])
                                .isNotEmpty
                            ? Center(
                                child: PaginatedListWidget(
                                  scrollController: scrollController,
                                  onPaginate: (pageIndex) {
                                    productProvider.initCategoryProductList(
                                      widget.categoryId,
                                      pageIndex ?? 1,
                                    );
                                  },
                                  totalSize: productProvider
                                      .subCategoryProductList
                                      ?.totalSize,
                                  offset: productProvider
                                      .subCategoryProductList
                                      ?.offset,
                                  itemView: SizedBox(
                                    width: Dimensions.webScreenWidth,
                                    child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisSpacing:
                                                ResponsiveHelper.isDesktop(
                                                  context,
                                                )
                                                ? 13
                                                : 10,
                                            mainAxisSpacing:
                                                ResponsiveHelper.isDesktop(
                                                  context,
                                                )
                                                ? 13
                                                : 10,
                                            childAspectRatio:
                                                ResponsiveHelper.isDesktop(
                                                  context,
                                                )
                                                ? (1 / 1.4)
                                                : (1 / 1.8),
                                            crossAxisCount:
                                                ResponsiveHelper.isDesktop(
                                                  context,
                                                )
                                                ? 5
                                                : 2,
                                          ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical: Dimensions.paddingSizeSmall,
                                      ),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: productProvider
                                          .subCategoryProductList
                                          ?.products
                                          ?.length,
                                      shrinkWrap: true,

                                      itemBuilder:
                                          (BuildContext context, int index) {
                                            return ProductWidget(
                                              product: productProvider
                                                  .subCategoryProductList!
                                                  .products![index],
                                              isCenter: true,
                                              isGrid: true,
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: SizedBox(
                                  width: Dimensions.webScreenWidth,
                                  child: (productProvider.hasData ?? false)
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                          ),
                                          child: _ProductShimmer(
                                            isEnabled: true,
                                          ),
                                        )
                                      : NoDataWidget(
                                          isFooter: false,
                                          title: getTranslated(
                                            'not_product_found',
                                            context,
                                          ),
                                        ),
                                ),
                              ),
                      ),

                      const FooterWebWidget(footerType: FooterType.sliver),
                    ],
                  ),
                ),

                const CategoryCartTitleWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SubcategoryTitleShimmer extends StatelessWidget {
  const _SubcategoryTitleShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 20),
      itemCount: 5,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeExtraSmall,
              ),
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).textTheme.titleLarge!.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                height: 20,
                width: 60,
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ColorResources.getGreyColor(context),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductShimmer extends StatelessWidget {
  final bool isEnabled;

  const _ProductShimmer({required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 10,
        childAspectRatio: ResponsiveHelper.isDesktop(context)
            ? (1 / 1.4)
            : (1 / 1.6),
        crossAxisCount: ResponsiveHelper.isDesktop(context)
            ? 5
            : ResponsiveHelper.isTab(context)
            ? 2
            : 2,
      ),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) =>
          const WebProductShimmerWidget(isEnabled: true),
      itemCount: 20,
    );
  }
}
