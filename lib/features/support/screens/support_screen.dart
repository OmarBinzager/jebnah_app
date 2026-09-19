import 'package:flutter/material.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/app_localization.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_button_widget.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../features/product/widgets/details_app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : const DetailsAppBarWidget(),

        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ResponsiveHelper.isDesktop(context)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeExtraLarge,
                      ),
                      child: Center(
                        child: Text(
                          "contact_us".tr,
                          style: poppinsSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),

            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Container(
                    width: width > 700 ? 700 : width,
                    padding: width > 700
                        ? const EdgeInsets.all(Dimensions.paddingSizeDefault)
                        : null,
                    decoration: width > 700
                        ? BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          )
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            Images.support,
                            height: 300,
                            width: 300,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).primaryColor,
                              size: 25,
                            ),
                            Text(
                              getTranslated('store_address', context),
                              style: poppinsMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Text(
                          Provider.of<SplashProvider>(
                                context,
                                listen: false,
                              ).configModel?.ecommerceAddress ??
                              'no address',
                          style: poppinsRegular,
                          textAlign: TextAlign.center,
                        ),
                        const Divider(thickness: 2),
                        const SizedBox(height: 50),

                        Padding(
                          padding: ResponsiveHelper.isDesktop(context)
                              ? const EdgeInsets.all(
                                  Dimensions.paddingSizeLarge,
                                )
                              : const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        width: 2,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    minimumSize: const Size(1, 50),
                                  ),
                                  onPressed: () {
                                    launchUrlString(
                                      'tel:${Provider.of<SplashProvider>(context, listen: false).configModel?.ecommercePhone}',
                                    );
                                  },
                                  child: Text(
                                    getTranslated('call_now', context),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: Dimensions.fontSizeLarge,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: CustomButtonWidget(
                                    buttonText: getTranslated(
                                      'send_a_message',
                                      context,
                                    ),
                                    onPressed: () async {
                                      RouteHelper.getChatRoute(
                                        orderId: "",
                                        senderType: "admin",
                                        userName: "",
                                        profileImage: "",
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const FooterWebWidget(footerType: FooterType.sliver),
          ],
        ),
      ),
    );
  }
}
