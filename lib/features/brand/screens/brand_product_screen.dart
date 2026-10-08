import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/enums/footer_type_enum.dart';
import '../../../common/widgets/custom_app_bar_widget.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/no_data_widget.dart';
import '../../../common/widgets/web_product_shimmer_widget.dart';
import '../../../common/widgets/product_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../providers/brand_provider.dart';

class BrandProductScreen extends StatefulWidget {
  final String brandId;
  final String? brandName;

  const BrandProductScreen({
    super.key,
    required this.brandId,
    this.brandName,
  });

  @override
  State<BrandProductScreen> createState() => _BrandProductScreenState();
}

class _BrandProductScreenState extends State<BrandProductScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<BrandProvider>(context, listen: false).getBrandProducts(
        context,
        widget.brandId,
        reload: true,
      );
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final brandProvider =
            Provider.of<BrandProvider>(context, listen: false);
        if (!brandProvider.isLoading && brandProvider.hasMoreProducts) {
          brandProvider.getBrandProducts(
            context,
            widget.brandId,
            reload: false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Provider.of<BrandProvider>(context, listen: false).getBrandProducts(
      context,
      widget.brandId,
      reload: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    String? appBarText = '';
    if (widget.brandName != null && widget.brandName != 'null') {
      appBarText = widget.brandName;
    } else {
      appBarText = getTranslated('brand', context);
    }

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: (ResponsiveHelper.isDesktop(context) || kIsWeb)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : CustomAppBarWidget(
                title: appBarText,
                isCenter: false,
                isElevation: true,
              ) as PreferredSizeWidget?,
        body: Consumer<BrandProvider>(
          builder: (context, brandProvider, child) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.webScreenWidth,
                        child: brandProvider.isLoading &&
                                brandProvider.brandProducts.isEmpty
                            ? GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing:
                                      ResponsiveHelper.isDesktop(context)
                                          ? 13
                                          : 10,
                                  mainAxisSpacing:
                                      ResponsiveHelper.isDesktop(context)
                                          ? 13
                                          : 10,
                                  childAspectRatio:
                                      ResponsiveHelper.isDesktop(context)
                                          ? (1 / 1.4)
                                          : (1 / 1.8),
                                  crossAxisCount:
                                      ResponsiveHelper.isDesktop(context)
                                          ? 5
                                          : 2,
                                ),
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall,
                                ),
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 10,
                                shrinkWrap: true,
                                itemBuilder: (context, index) =>
                                    const WebProductShimmerWidget(
                                  isEnabled: true,
                                ),
                              )
                            : brandProvider.brandProducts.isNotEmpty
                                ? Column(
                                    children: [
                                      GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisSpacing:
                                              ResponsiveHelper.isDesktop(
                                                      context)
                                                  ? 13
                                                  : 10,
                                          mainAxisSpacing:
                                              ResponsiveHelper.isDesktop(
                                                      context)
                                                  ? 13
                                                  : 10,
                                          childAspectRatio:
                                              ResponsiveHelper.isDesktop(
                                                      context)
                                                  ? (1 / 1.4)
                                                  : (1 / 1.8),
                                          crossAxisCount:
                                              ResponsiveHelper.isDesktop(
                                                      context)
                                                  ? 5
                                                  : 2,
                                        ),
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall,
                                        ),
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: brandProvider
                                            .brandProducts.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return ProductWidget(
                                            product: brandProvider
                                                .brandProducts[index],
                                            isCenter: true,
                                            isGrid: true,
                                          );
                                        },
                                      ),
                                      if (brandProvider.isLoading &&
                                          brandProvider
                                              .brandProducts.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall,
                                          ),
                                          child: CustomLoaderWidget(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                    ],
                                  )
                                : SizedBox(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.6,
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
                      ),
                    ),
                  ),
                  const FooterWebWidget(footerType: FooterType.sliver),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
