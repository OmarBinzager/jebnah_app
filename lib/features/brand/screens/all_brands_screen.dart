import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../common/widgets/custom_app_bar_widget.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../common/widgets/no_data_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../brand/domain/models/brand_model.dart';
import '../../brand/providers/brand_provider.dart';
import '../../brand/widgets/brand_item_widget.dart';
import '../../brand/widgets/brand_products_shimmer_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';

import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

import '../../splash/providers/splash_provider.dart';

class AllBrandsScreen extends StatefulWidget {
  const AllBrandsScreen({super.key});

  @override
  State<AllBrandsScreen> createState() => _AllBrandsScreenState();
}

class _AllBrandsScreenState extends State<AllBrandsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final brandProvider = Provider.of<BrandProvider>(context, listen: false);
      if (brandProvider.brandList != null && brandProvider.brandList!.isNotEmpty) {
        _load();
      } else {
        brandProvider.getBrandList(context, true).then((_) {
          if (!mounted) return;
          if (brandProvider.brandList != null &&
              brandProvider.brandList!.isNotEmpty) {
            _load();
          }
        });
      }
    });
  }

  Future<void> _load() async {
    if (!mounted) return;
    final brandProvider = Provider.of<BrandProvider>(context, listen: false);
    int selectedIndex = brandProvider.brandIndex;
    if (selectedIndex < 0 ||
        selectedIndex >= (brandProvider.brandList?.length ?? 0)) {
      selectedIndex = 0;
      brandProvider.onChangeBrandIndex(0, notify: false);
    }

    if (brandProvider.brandList?.isNotEmpty ?? false) {
      brandProvider.getBrandProducts(
        context,
        brandProvider.brandList![selectedIndex].id.toString(),
        reload: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: (ResponsiveHelper.isDesktop(context) || kIsWeb)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : CustomAppBarWidget(
                title: getTranslated('brands', context),
              ) as PreferredSizeWidget?,
        body: Center(
          child: SizedBox(
            width: Dimensions.webScreenWidth,
            child: Consumer<BrandProvider>(
              builder: (context, brandProvider, child) {
                return brandProvider.brandList == null
                    ? Center(
                        child: CustomLoaderWidget(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : brandProvider.brandList?.isNotEmpty ?? false
                    ? Row(
                        children: [
                          // القائمة الجانبية للعلامات التجارية
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
                              itemCount: brandProvider.brandList!.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              itemBuilder: (context, index) {
                                BrandModel brand =
                                    brandProvider.brandList![index];
                                return InkWell(
                                  onTap: () {
                                    brandProvider.onChangeBrandIndex(index);
                                    // جلب منتجات العلامة التجارية عند النقر عليها
                                    brandProvider.getBrandProducts(
                                      context,
                                      brand.id.toString(),
                                      reload: true,
                                    );
                                  },
                                  child: BrandItemWidget(
                                    title: brand.name,
                                    icon:
                                        '${Provider.of<SplashProvider>(context, listen: false).baseUrls?.brandImageUrl}/${brandProvider.brandList![index].image}',

                                    isSelected:
                                        brandProvider.brandIndex == index,
                                  ),
                                );
                              },
                            ),
                          ),

                          // عرض منتجات العلامة التجارية المحددة
                          brandProvider.isLoading
                              ? const Expanded(
                                  child: BrandProductsShimmerWidget(),
                                )
                              : brandProvider.brandProducts.isNotEmpty
                                  ? Expanded(
                                      child: ListView.separated(
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall,
                                        ),
                                        itemCount:
                                            brandProvider.brandProducts.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index == 0) {
                                            // خيار "كل المنتجات"
                                            return ListTile(
                                              onTap: () {
                                                brandProvider.onChangeSelectIndex(
                                                  -1,
                                                );
                                              },
                                              title: Text(
                                                getTranslated(
                                                  'all_products',
                                                  context,
                                                ),
                                                style: poppinsMedium.copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              trailing: const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                              ),
                                            );
                                          }

                                          final productIndex = index - 1;
                                          final product = brandProvider
                                              .brandProducts[productIndex];

                                          return ListTile(
                                            onTap: () {
                                              brandProvider.onChangeSelectIndex(
                                                productIndex,
                                              );
                                              if (product.id != null) {
                                                RouteHelper.getProductDetailsRoute(
                                                  productId: product.id,
                                                );
                                              }
                                            },
                                            title: Text(
                                              product.name ?? '',
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
                                            subtitle: product.price != null
                                                ? Text(
                                                    '${product.price} ${getTranslated('currency_symbol', context)}',
                                                    style: poppinsRegular.copyWith(
                                                      fontSize: 11,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                  )
                                                : null,
                                            trailing: const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 14,
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
                                  : Expanded(
                                      child: Center(
                                        child: NoDataWidget(
                                          title: getTranslated(
                                            'not_found',
                                            context,
                                          ),
                                          isShowButton: false,
                                          isFooter: false,
                                        ),
                                      ),
                                    ),
                        ],
                      )
                    : NoDataWidget(
                        title: getTranslated('brands_not_found', context),
                      );
              },
            ),
          ),
        ),
      ),
    );
  }
}
