import 'package:flutter/material.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../features/coupon/widgets/coupon_bottom_sheet_widget.dart';
import '../../../features/coupon/widgets/coupon_card_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/coupon/providers/coupon_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/app_bar_base_widget.dart';
import '../../../common/widgets/no_data_widget.dart';
import '../../../common/widgets/not_login_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/footer_web_widget.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  @override
  void initState() {
    super.initState();

    final bool isLoggedIn = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();

    final bool isGuestCheckout =
        Provider.of<SplashProvider>(
          context,
          listen: false,
        ).configModel?.isGuestCheckout ??
        false;

    if (isLoggedIn || isGuestCheckout) {
      Provider.of<CouponProvider>(
        context,
        listen: false,
      ).getCouponList(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isLoggedIn = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();
    final bool isGuestCheckout =
        Provider.of<SplashProvider>(
          context,
          listen: false,
        ).configModel?.isGuestCheckout ??
        false;
    final height = MediaQuery.of(context).size.height;

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isMobilePhone()
            ? null
            : (ResponsiveHelper.isDesktop(context)
                      ? const PreferredSize(
                          preferredSize: Size.fromHeight(120),
                          child: WebAppBarWidget(),
                        )
                      : const AppBarBaseWidget())
                  as PreferredSizeWidget?,
        body: isLoggedIn || isGuestCheckout
            ? Consumer<CouponProvider>(
                builder: (context, couponProvider, child) {
                  return couponProvider.couponList == null
                      ? Center(
                          child: CustomLoaderWidget(
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : (couponProvider.couponList?.isNotEmpty ?? false)
                      ? RefreshIndicator(
                          onRefresh: () async {
                            await couponProvider.getCouponList(context);
                          },
                          backgroundColor: Theme.of(context).primaryColor,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight:
                                          !ResponsiveHelper.isDesktop(
                                                context,
                                              ) &&
                                              height < 600
                                          ? height
                                          : height - 400,
                                    ),
                                    child: Container(
                                      padding: width > 700
                                          ? const EdgeInsets.all(
                                              Dimensions.paddingSizeLarge,
                                            )
                                          : EdgeInsets.zero,
                                      child: Container(
                                        width: width > 700
                                            ? Dimensions.webScreenWidth
                                            : width,
                                        padding: width > 700
                                            ? const EdgeInsets.all(
                                                Dimensions.paddingSizeDefault,
                                              )
                                            : null,
                                        decoration: width > 700
                                            ? BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).canvasColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(
                                                      context,
                                                    ).shadowColor,
                                                    offset: const Offset(
                                                      10,
                                                      18,
                                                    ),
                                                    blurRadius: 35,
                                                  ),
                                                ],
                                              )
                                            : null,
                                        child: Column(
                                          children: [
                                            ResponsiveHelper.isDesktop(context)
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          Dimensions
                                                              .paddingSizeLarge,
                                                        ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          getTranslated(
                                                            'coupon_list',
                                                            context,
                                                          ),
                                                          style: poppinsBold.copyWith(
                                                            fontSize: Dimensions
                                                                .paddingSizeLarge,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),

                                                        // const _SearchTextFieldWidget(),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),

                                            // const Padding(
                                            //   padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
                                            //   child: _SearchTextFieldWidget(),
                                            // ),
                                            ResponsiveHelper.isDesktop(context)
                                                ? GridView.builder(
                                                    itemCount: couponProvider
                                                        .couponList
                                                        ?.length,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeLarge,
                                                          vertical: Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                    gridDelegate:
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount:
                                                              3, // Change this value based on desired column count
                                                          mainAxisSpacing: 15,
                                                          crossAxisSpacing: 15,
                                                          childAspectRatio:
                                                              2.8, // Adjust based on desired item shape
                                                        ),
                                                    itemBuilder: (context, index) {
                                                      return InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          ResponsiveHelper()
                                                              .showDialogOrBottomSheet(
                                                                context,
                                                                AlertDialog(
                                                                  content: CouponBottomSheetWidget(
                                                                    coupon: couponProvider
                                                                        .couponList?[index],
                                                                  ),
                                                                  insetPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                ),
                                                              );
                                                        },
                                                        child: CouponCardWidget(
                                                          coupon: couponProvider
                                                              .couponList?[index],
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : ListView.builder(
                                                    itemCount: couponProvider
                                                        .couponList
                                                        ?.length,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeLarge,
                                                          vertical: Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                    itemBuilder: (context, index) {
                                                      return InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          ResponsiveHelper()
                                                              .showDialogOrBottomSheet(
                                                                context,
                                                                CouponBottomSheetWidget(
                                                                  coupon: couponProvider
                                                                      .couponList?[index],
                                                                ),
                                                              );
                                                        },
                                                        child: CouponCardWidget(
                                                          coupon: couponProvider
                                                              .couponList?[index],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (ResponsiveHelper.isDesktop(context))
                                  const FooterWebWidget(
                                    footerType: FooterType.nonSliver,
                                  ),
                              ],
                            ),
                          ),
                        )
                      : NoDataWidget(
                          title: getTranslated('coupon_not_found', context),
                        );
                },
              )
            : const NotLoggedInWidget(),
      ),
    );
  }
}

class _SearchTextFieldWidget extends StatefulWidget {
  const _SearchTextFieldWidget();

  @override
  State<_SearchTextFieldWidget> createState() => _SearchTextFieldWidgetState();
}

class _SearchTextFieldWidgetState extends State<_SearchTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CouponProvider>(
      builder: (context, coupon, child) {
        return SizedBox(
          width: ResponsiveHelper.isDesktop(context)
              ? MediaQuery.of(context).size.width * 0.2
              : null,
          child: TextField(
            //controller: coupon.searchController,
            style: poppinsRegular.copyWith(
              color: Theme.of(context).textTheme.bodyLarge!.color,
              fontSize: Dimensions.fontSizeDefault,
            ),

            cursorColor: Theme.of(context).hintColor,
            autofocus: false,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.search,
            onChanged: (text) {
              // coupon.showSuffixIcon(context,text);
              // if(text.isNotEmpty) {
              //   coupon.searchCoupon(query : text.trim());
              // }
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
              ),

              isDense: true,
              hintText: getTranslated('search_by_name_code', context),
              hintStyle: poppinsRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).hintColor,
              ),
              filled: true,
              suffixIconConstraints: BoxConstraints(maxHeight: 40),
              suffixIcon: IconButton(
                color: Theme.of(context).hintColor,
                padding: EdgeInsets.zero,
                onPressed: () {
                  // if(coupon.searchController.text.trim().isNotEmpty) {
                  //   coupon.clearSearchController();
                  // }
                  // FocusScope.of(context).unfocus();
                },
                icon: Icon(
                  Icons.search_outlined,
                  color: Theme.of(context).hintColor,
                  size: 22,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
