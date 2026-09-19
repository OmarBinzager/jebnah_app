import 'package:flutter/material.dart';
import 'package:jebnah/features/brand/providers/brand_provider.dart';
import '../../../common/enums/data_source_enum.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/models/config_model.dart';
import '../../../common/providers/localization_provider.dart';
import '../../../common/providers/product_provider.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/title_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/category/providers/category_provider.dart';
import '../providers/banner_provider.dart';
import '../../../features/home/providers/flash_deal_provider.dart';
import '../../../features/home/widgets/all_product_list_widget.dart';

import '../../../features/home/widgets/category_web_widget.dart';
import '../../../features/home/widgets/flash_deal_home_card_widget.dart';
import '../../../features/home/widgets/home_item_widget.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../features/wishlist/providers/wishlist_provider.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../main.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import '../../../utill/product_type.dart';
import 'package:provider/provider.dart';

import '../widgets/brand_carousel_widget.dart';
import '../widgets/carousel_horizontal_banners_widget.dart';
import '../widgets/category_grid2x2_widget.dart';
import '../widgets/grid2x2_banners_widget.dart';
import '../widgets/top_banners_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Future<void> loadData(
    bool reload,
    BuildContext context, {
    bool fromLanguage = false,
  }) async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final flashDealProvider = Provider.of<FlashDealProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final withLListProvider = Provider.of<WishListProvider>(
      context,
      listen: false,
    );
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );

    ConfigModel? config = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel;
    if (reload) {
      Provider.of<SplashProvider>(
        context,
        listen: false,
      ).initConfig(context, source: DataSourceEnum.client);
      Provider.of<SplashProvider>(context, listen: false).getDeliveryInfo();
    }
    if (fromLanguage &&
        (authProvider.isLoggedIn() || (config?.isGuestCheckout ?? false))) {
      localizationProvider.changeLanguage();
    }
    Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).getCategoryList(context, reload);

    Provider.of<BannerProvider>(
      context,
      listen: false,
    ).getBannerList(context, reload);

    Provider.of<BrandProvider>(
      context,
      listen: false,
    ).getBrandList(context, reload);

    if (productProvider.dailyProductModel == null || reload) {
      productProvider.getItemList(
        1,
        isUpdate: false,
        productType: ProductType.dailyItem,
      );
    }

    if (productProvider.mostViewedProductModel == null || reload) {
      productProvider.getItemList(
        1,
        isUpdate: false,
        productType: ProductType.mostReviewed,
      );
    }

    productProvider.getAllProductList(1, reload, isUpdate: false);

    if (authProvider.isLoggedIn()) {
      withLListProvider.getWishListProduct();
    }

    if ((config?.flashDealProductStatus ?? false) &&
        (flashDealProvider.flashDealModel == null || reload)) {
      flashDealProvider.getFlashDealProducts(1, isUpdate: false);
    }
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Provider.of<OrderProvider>(context, listen: false).manageDialog();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await HomeScreen.loadData(true, context);
        Provider.of<OrderProvider>(Get.context!, listen: false).manageDialog();
      },
      backgroundColor: Theme.of(context).primaryColor,
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : null,
        body: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: SizedBox(
                  width: Dimensions.webScreenWidth,
                  child: Column(
                    children: [
                      /// قسم الفئات بدون صور (أسماء فقط بشكل أفقي)
                      Consumer<CategoryProvider>(
                        builder: (context, categoryProvider, child) {
                          if (categoryProvider.categoryList == null ||
                              categoryProvider.categoryList!.isEmpty) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                            child: _buildTextOnlyCategories(categoryProvider),
                          );
                        },
                      ),

                      /// قسم الفئات مع الصور (كما هي موجودة)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: ResponsiveHelper.isDesktop(context)
                              ? Dimensions.paddingSizeLarge
                              : Dimensions.fontSizeExtraLarge,
                        ),
                        child: const CategoryWidget(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Consumer<BannerProvider>(
                          builder: (context, banner, child) {
                            return (banner.bannerList?.isEmpty ?? false)
                                ? const SizedBox()
                                : const TopBannersWidget();
                          },
                        ),
                      ),

                      SizedBox(height: Dimensions.paddingSizeSmall),
                      Consumer<BannerProvider>(
                        builder: (context, banner, child) {
                          return (banner.bannerList?.isEmpty ?? false)
                              ? const SizedBox()
                              : const CarouselHorizontalBannersWidget();
                        },
                      ),

                      SizedBox(height: Dimensions.paddingSizeSmall),
                      Consumer<BannerProvider>(
                        builder: (context, banner, child) {
                          return (banner.bannerList?.isEmpty ?? false)
                              ? const SizedBox()
                              : const Grid2x2BannersWidget();
                        },
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                          bottom: ResponsiveHelper.isDesktop(context)
                              ? Dimensions.paddingSizeLarge
                              : Dimensions.paddingSizeSmall,
                        ),
                        child: const CategoryGrid2x2Widget(),
                      ),

                      const BrandCarouselWidget(),

                      /// Flash Deal
                      Selector<SplashProvider, ConfigModel?>(
                        selector: (ctx, splashProvider) =>
                            splashProvider.configModel,
                        builder: (context, configModel, _) {
                          return (configModel?.flashDealProductStatus ?? false)
                              ? const FlashDealHomeCardWidget()
                              : const SizedBox();
                        },
                      ),

                      Consumer<ProductProvider>(
                        builder: (context, productProvider, child) {
                          bool isDalyProduct =
                              (productProvider.dailyProductModel == null ||
                              (productProvider
                                      .dailyProductModel
                                      ?.products
                                      ?.isNotEmpty ??
                                  false));
                          bool isFeaturedProduct =
                              (productProvider.featuredProductModel == null ||
                              (productProvider
                                      .featuredProductModel
                                      ?.products
                                      ?.isNotEmpty ??
                                  false));
                          bool isMostViewedProduct =
                              (productProvider.mostViewedProductModel == null ||
                              (productProvider
                                      .mostViewedProductModel
                                      ?.products
                                      ?.isNotEmpty ??
                                  false));

                          return Column(
                            children: [
                              isDalyProduct
                                  ? Column(
                                      children: [
                                        TitleWidget(
                                          title: getTranslated(
                                            'daily_needs',
                                            context,
                                          ),
                                          onTap: () {
                                            RouteHelper.getHomeItemRoute(
                                              ProductType.dailyItem,
                                            );
                                          },
                                        ),
                                        HomeItemWidget(
                                          productList: productProvider
                                              .dailyProductModel
                                              ?.products,
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),

                              if (isMostViewedProduct)
                                Selector<SplashProvider, ConfigModel?>(
                                  selector: (ctx, splashProvider) =>
                                      splashProvider.configModel,
                                  builder: (context, configModel, _) {
                                    return (configModel
                                                ?.mostReviewedProductStatus ??
                                            false)
                                        ? Column(
                                            children: [
                                              TitleWidget(
                                                title: getTranslated(
                                                  ProductType.mostReviewed,
                                                  context,
                                                ),
                                                onTap: () {
                                                  RouteHelper.getHomeItemRoute(
                                                    ProductType.mostReviewed,
                                                  );
                                                },
                                              ),
                                              HomeItemWidget(
                                                productList: productProvider
                                                    .mostViewedProductModel
                                                    ?.products,
                                              ),
                                            ],
                                          )
                                        : const SizedBox();
                                  },
                                ),
                            ],
                          );
                        },
                      ),

                      ResponsiveHelper.isMobilePhone()
                          ? const SizedBox(height: 10)
                          : const SizedBox.shrink(),

                      AllProductListWidget(scrollController: scrollController),
                    ],
                  ),
                ),
              ),
            ),

            if (ResponsiveHelper.isWeb()) ...[
              const FooterWebWidget(footerType: FooterType.sliver),
            ],
          ],
        ),
      ),
    );
  }

  // دالة لبناء الفئات بدون صور (نص فقط) بشكل أفقي
  Widget _buildTextOnlyCategories(CategoryProvider categoryProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم مع خط تحته
        Container(
          margin: const EdgeInsets.only(
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            bottom: Dimensions.paddingSizeSmall,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start),
        ),

        // قائمة الفئات الأفقية
        SizedBox(
          height: 40, // تقليل الارتفاع
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: categoryProvider.categoryList!.length,
            itemBuilder: (context, index) {
              final category = categoryProvider.categoryList![index];
              return GestureDetector(
                onTap: () {
                  categoryProvider.onChangeSelectIndex(-1, notify: false);
                  RouteHelper.getCategoryProductsRoute(
                    categoryId: '${category.id}',
                    categoryName: '${category.name}',
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(
                    right: Dimensions
                        .paddingSizeDefault, // تقليل المسافة بين العناصر
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions
                        .paddingSizeExtraSmall, // تقليل المسافة العمودية
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white, // خلفية بيضاء
                    borderRadius: BorderRadius.circular(
                      Dimensions.paddingSizeDefault,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade300, // حد رمادي فاتح
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category.name ?? '',
                      style: poppinsMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: Colors.black87, // لون أسود للنص
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // تقليل المساحة السفلية
      ],
    );
  }
}
