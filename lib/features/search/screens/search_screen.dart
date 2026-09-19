import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../common/providers/cart_provider.dart';
import '../../../common/providers/theme_provider.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../common/widgets/custom_text_field_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../category/providers/category_provider.dart';
import '../../splash/providers/splash_provider.dart';
import '../providers/search_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int? pageSize;
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<SearchProvider>(context, listen: false).initHistoryList();
    Provider.of<SearchProvider>(
      context,
      listen: false,
    ).initializeAllSortBy(notify: false);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
            ),
            child: Center(
              child: SizedBox(
                width: Dimensions.webScreenWidth,
                child: Consumer<SearchProvider>(
                  builder: (context, searchProvider, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),

                          Expanded(
                            child: CustomTextFieldWidget(
                              fillColor: Theme.of(
                                context,
                              ).disabledColor.withValues(alpha: 0.001),
                              hintText: getTranslated(
                                'type_to_search',
                                context,
                              ),
                              isShowBorder: true,
                              controller: _searchController,
                              inputAction: TextInputAction.search,
                              isIcon: true,
                              onSubmit: (text) {
                                if (_searchController.text.isNotEmpty) {
                                  searchProvider.saveSearchAddress(
                                    _searchController.text,
                                  );
                                  RouteHelper.getSearchResultRoute(
                                    _searchController.text,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          InkWell(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  color: Theme.of(context).hintColor.withValues(
                                    alpha:
                                        Provider.of<ThemeProvider>(
                                          context,
                                          listen: false,
                                        ).darkTheme
                                        ? 0.9
                                        : 0.4,
                                  ),
                                  size: 25,
                                ),

                                Positioned(
                                  top: -7,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    child: Text(
                                      '${Provider.of<CartProvider>(context).getTotalCartQuantity()}',
                                      style: TextStyle(
                                        color: Theme.of(context).cardColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Provider.of<SplashProvider>(
                                context,
                                listen: false,
                              ).setPageIndex(2);
                              RouteHelper.getMainRoute(
                                action: RouteAction.pushReplacement,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslated('recent_search', context),
                            style: poppinsBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),

                          searchProvider.historyList.isNotEmpty
                              ? InkWell(
                                  onTap: searchProvider.clearSearchAddress,
                                  child: Text(
                                    getTranslated('clear_all', context),
                                    style: poppinsSemiBold.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.7),
                                      fontSize: Dimensions.fontSizeLarge,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      // for recent search list section
                      Flexible(
                        child: ListView.separated(
                          itemCount: searchProvider.historyList.length,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) => Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      searchProvider.getSearchProduct(
                                        offset: 1,
                                        query:
                                            searchProvider.historyList[index]!,
                                      );
                                      RouteHelper.getSearchResultRoute(
                                        searchProvider.historyList[index]!,
                                      );
                                    },
                                    child: Text(
                                      searchProvider.historyList[index]!,
                                      style: poppinsSemiBold.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withValues(alpha: 0.7),
                                        fontSize: Dimensions.fontSizeLarge,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              InkWell(
                                //onTap: ,  ///TODO
                                child: Image.asset(
                                  Images.crossIcon,
                                  height: 12,
                                  width: 12,
                                ),
                              ),
                            ],
                          ),
                          separatorBuilder: (context, idx) => Divider(
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Text(
                        getTranslated('popular_categories', context),
                        style: poppinsBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Wrap(
                        children:
                            Provider.of<CategoryProvider>(
                              context,
                              listen: false,
                            ).categoryList!.map((categoryData) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  top: Dimensions.paddingSizeExtraSmall,
                                  right: Dimensions.paddingSizeSmall,
                                ),
                                child: InkWell(
                                  onTap: () =>
                                      RouteHelper.getCategoryProductsRoute(
                                        categoryId: '${categoryData.id}',
                                        categoryName: '${categoryData.name}',
                                      ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical:
                                          Dimensions.paddingSizeExtraSmall,
                                      horizontal: Dimensions.paddingSizeSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).hintColor.withValues(alpha: 0.1),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.paddingSizeExtraSmall,
                                      ),
                                    ),
                                    child: Text(categoryData.name ?? ''),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
