import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../common/enums/footer_type_enum.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/no_data_widget.dart';
import '../../../common/widgets/paginated_list_widget.dart';
import '../../../common/widgets/product_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../common/widgets/web_product_shimmer_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/product_type.dart';
import '../../../utill/styles.dart';
import '../../splash/providers/splash_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/filter_widget.dart';

class SearchResultScreen extends StatefulWidget {
  final String? searchString;

  const SearchResultScreen({super.key, this.searchString});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    final SearchProvider searchProvider = Provider.of<SearchProvider>(
      context,
      listen: false,
    );

    searchProvider.initHistoryList();
    searchProvider.initializeAllSortBy(notify: false);
    searchProvider.saveSearchAddress(widget.searchString, isUpdate: false);
    searchProvider.getSearchProduct(
      offset: 1,
      query: widget.searchString ?? '',
      isUpdate: false,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
            ),
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) => CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.webScreenWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),

                            !ResponsiveHelper.isDesktop(context)
                                ? Row(
                                    children: [
                                      Flexible(
                                        child: InkWell(
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: Container(
                                            height: 48,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            width: MediaQuery.of(
                                              context,
                                            ).size.width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions
                                                        .radiusSizeDefault,
                                                  ),
                                              color: Theme.of(context)
                                                  .disabledColor
                                                  .withValues(alpha: 0.02),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.05),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  Images.search,
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall,
                                                ),

                                                Text(
                                                  widget.searchString!,
                                                  style: poppinsLight.copyWith(
                                                    fontSize: Dimensions
                                                        .paddingSizeLarge,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      InkWell(
                                        onTap: () {
                                          if (Navigator.canPop(context)) {
                                            Navigator.pop(context);
                                            return;
                                          } else {
                                            Provider.of<SplashProvider>(
                                              context,
                                            ).setPageIndex(0);
                                            RouteHelper.getMainRoute(
                                              action: RouteAction
                                                  .pushNamedAndRemoveUntil,
                                            );
                                            return;
                                          }
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                          size: 25,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Container(
                              height: ResponsiveHelper.isDesktop(context)
                                  ? 48
                                  : 60,
                              margin: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${searchProvider.searchProductModel?.products?.length ?? 0} ",
                                        style: poppinsMedium,
                                      ),
                                      Text(
                                        getTranslated('items_found', context),
                                        style: poppinsMedium,
                                      ),
                                    ],
                                  ),
                                  searchProvider.searchProductModel?.products !=
                                          null
                                      ? InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  insetPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal:
                                                            ResponsiveHelper.isDesktop(
                                                              context,
                                                            )
                                                            ? 200
                                                            : 20,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20.0,
                                                        ),
                                                  ),
                                                  child: FilterWidget(
                                                    query: widget.searchString,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  ResponsiveHelper.isDesktop(
                                                    context,
                                                  )
                                                  ? Dimensions.paddingSizeLarge
                                                  : Dimensions.paddingSizeSmall,
                                              vertical:
                                                  ResponsiveHelper.isDesktop(
                                                    context,
                                                  )
                                                  ? Dimensions
                                                        .paddingSizeExtraSmall
                                                  : Dimensions.paddingSizeSmall,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                ResponsiveHelper.isDesktop(
                                                      context,
                                                    )
                                                    ? Text(
                                                        getTranslated(
                                                          'filter',
                                                          context,
                                                        ),
                                                        style: poppinsMedium
                                                            .copyWith(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                            ),
                                                      )
                                                    : const SizedBox(),
                                                SizedBox(
                                                  width:
                                                      ResponsiveHelper.isDesktop(
                                                        context,
                                                      )
                                                      ? Dimensions
                                                            .paddingSizeSmall
                                                      : 0,
                                                ),

                                                Icon(
                                                  Icons.filter_list,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),

                            //const SizedBox(height: 22),
                            searchProvider.searchProductModel?.products == null
                                ? GridView.builder(
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
                                              : (1 / 1.7),
                                          crossAxisCount:
                                              ResponsiveHelper.isDesktop(
                                                context,
                                              )
                                              ? 5
                                              : ResponsiveHelper.isTab(context)
                                              ? 2
                                              : 2,
                                        ),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: 10,
                                    itemBuilder: (context, index) =>
                                        const WebProductShimmerWidget(
                                          isEnabled: true,
                                        ),
                                  )
                                : (searchProvider
                                          .searchProductModel
                                          ?.products
                                          ?.isNotEmpty ??
                                      false)
                                ? PaginatedListWidget(
                                    scrollController: scrollController,
                                    onPaginate: (offset) async =>
                                        await searchProvider.getSearchProduct(
                                          offset: offset ?? 1,
                                          query: widget.searchString ?? '',
                                          priceLow: searchProvider.lowerValue,
                                          priceHigh: searchProvider.upperValue,
                                          filterType:
                                              searchProvider.selectedFilter,
                                        ),
                                    totalSize: searchProvider
                                        .searchProductModel
                                        ?.totalSize,
                                    offset: searchProvider
                                        .searchProductModel
                                        ?.offset,
                                    itemView: GridView.builder(
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
                                                : (1 / 1.7),
                                            crossAxisCount:
                                                ResponsiveHelper.isDesktop(
                                                  context,
                                                )
                                                ? 5
                                                : ResponsiveHelper.isTab(
                                                    context,
                                                  )
                                                ? 2
                                                : 2,
                                          ),
                                      itemCount: searchProvider
                                          .searchProductModel
                                          ?.products
                                          ?.length,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical: Dimensions.paddingSizeLarge,
                                      ),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext context, int index) =>
                                              ProductWidget(
                                                product: searchProvider
                                                    .searchProductModel!
                                                    .products![index],
                                                productType:
                                                    ProductType.searchItem,
                                                isGrid: true,
                                                isCenter: true,
                                              ),
                                    ),
                                  )
                                : NoDataWidget(
                                    isFooter: false,
                                    title: getTranslated(
                                      'not_product_found',
                                      context,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const FooterWebWidget(footerType: FooterType.sliver),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
