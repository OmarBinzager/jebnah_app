import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../../common/enums/footer_type_enum.dart';
import '../../../../helper/email_checker_helper.dart';
import '../../../../helper/responsive_helper.dart';
import '../../../../helper/route_helper.dart';
import '../../../../localization/app_localization.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../common/providers/localization_provider.dart';
import '../../../../common/providers/theme_provider.dart';
import '../../../../common/providers/news_letter_provider.dart';
import '../../../../features/splash/providers/splash_provider.dart';
import '../../../../utill/color_resources.dart';
import '../../../../utill/dimensions.dart';
import '../../../../utill/images.dart';
import '../../../../utill/styles.dart';
import '../../../../helper/custom_snackbar_helper.dart';
import '../../../../common/widgets/text_hover_widget.dart';
import '../../../../common/widgets/custom_asset_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FooterWebWidget extends StatelessWidget {
  final FooterType footerType;
  const FooterWebWidget({super.key, required this.footerType});

  @override
  Widget build(BuildContext context) {
    final TextEditingController newsLetterController = TextEditingController();
    final bool isLoggedIn = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrow = screenWidth < 850;

    final bool hasApps =
        (splashProvider.configModel?.playStoreConfig?.status ?? false) ||
        (splashProvider.configModel?.appStoreConfig?.status ?? false);

    return _FooterFormatter(
      footerType: footerType,
      child: Container(
        color: Theme.of(context).secondaryHeaderColor,
        width: double.maxFinite,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Dimensions.webScreenWidth),
            child: isNarrow
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeLarge,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLogoAndNewsletter(context, newsLetterController),
                        if (hasApps) ...[
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          _buildDownloadApps(context, splashProvider),
                        ],
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildMyAccount(context, isLoggedIn)),
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                            Expanded(child: _buildQuickLinks(context)),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        const Divider(thickness: 0.5),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildSocialMedia(context, splashProvider),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              _buildCopyright(context),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildLogoAndNewsletter(
                                context,
                                newsLetterController,
                              ),
                            ),
                            if (hasApps) ...[
                              const SizedBox(width: Dimensions.paddingSizeDefault),
                              Expanded(
                                flex: 3,
                                child: _buildDownloadApps(context, splashProvider),
                              ),
                            ],
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                            Expanded(
                              flex: 2,
                              child: _buildMyAccount(context, isLoggedIn),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                            Expanded(
                              flex: 2,
                              child: _buildQuickLinks(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        const Divider(thickness: 0.5),
                        SizedBox(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSocialMedia(context, splashProvider),
                              Flexible(child: _buildCopyright(context)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAndNewsletter(
    BuildContext context,
    TextEditingController newsLetterController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) => CustomAssetImageWidget(
            themeProvider.darkTheme
                ? Images.darkAppLogo
                : Images.webBarLogoPlaceHolder,
            width: 125,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Text(
          'news_letter'.tr,
          style: poppinsBold.copyWith(
            color: ColorResources.getFooterTextColor(context),
            fontSize: Dimensions.fontSizeExtraLarge,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          'subscribe_to_out_new_channel_to_get_latest_updates'.tr,
          style: poppinsRegular.copyWith(
            color: ColorResources.getFooterTextColor(context),
            fontSize: Dimensions.fontSizeDefault,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: TextField(
                  controller: newsLetterController,
                  style: poppinsRegular.copyWith(color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email,
                      color: Theme.of(context).disabledColor,
                    ),
                    hintText: 'your_email_address'.tr,
                    hintStyle: poppinsRegular.copyWith(
                      color: Theme.of(context).disabledColor,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                    border: InputBorder.none,
                  ),
                  maxLines: 1,
                ),
              ),
              InkWell(
                onTap: () {
                  String email = newsLetterController.text.trim();
                  if (email.isEmpty) {
                    showCustomSnackBarHelper('enter_email_address'.tr);
                  } else if (EmailCheckerHelper.isNotValid(email)) {
                    showCustomSnackBarHelper('enter_valid_email'.tr);
                  } else {
                    Provider.of<NewsLetterProvider>(
                      context,
                      listen: false,
                    ).addToNewsLetter(email).then((value) {
                      newsLetterController.clear();
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusSizeDefault,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Text(
                    'subscribe'.tr,
                    style: poppinsRegular.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadApps(
    BuildContext context,
    SplashProvider splashProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (splashProvider.configModel?.playStoreConfig?.status ?? false) &&
                  (splashProvider.configModel?.appStoreConfig?.status ?? false)
              ? 'download_our_apps'.tr
              : 'download_our_app'.tr,
          style: poppinsMedium.copyWith(
            color: ColorResources.getFooterTextColor(context),
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Wrap(
          spacing: Dimensions.paddingSizeSmall,
          runSpacing: Dimensions.paddingSizeSmall,
          children: [
            if (splashProvider.configModel?.playStoreConfig?.status ?? false)
              InkWell(
                onTap: () {
                  _launchURL(
                    splashProvider.configModel!.playStoreConfig!.link!,
                  );
                },
                child: Image.asset(
                  Images.playStore,
                  height: 45,
                  fit: BoxFit.contain,
                ),
              ),
            if (splashProvider.configModel?.appStoreConfig?.status ?? false)
              InkWell(
                onTap: () {
                  _launchURL(
                    splashProvider.configModel!.appStoreConfig!.link!,
                  );
                },
                child: Image.asset(
                  Images.appStore,
                  height: 45,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMyAccount(BuildContext context, bool isLoggedIn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'my_account'.tr,
          style: poppinsMedium.copyWith(
            color: ColorResources.getFooterTextColor(context),
            fontSize: Dimensions.fontSizeExtraLarge,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        _buildFooterLink(
          context,
          title: 'profile'.tr,
          onTap: () {
            isLoggedIn
                ? RouteHelper.getProfileEditRoute()
                : RouteHelper.getLoginRoute();
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        _buildFooterLink(
          context,
          title: 'address'.tr,
          onTap: () => RouteHelper.getAddressListScreen(),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        _buildFooterLink(
          context,
          title: 'live_chat'.tr,
          onTap: () {
            RouteHelper.getChatRoute(
              orderId: "",
              profileImage: "",
              userName: "",
              senderType: "admin",
            );
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        _buildFooterLink(
          context,
          title: 'my_order'.tr,
          onTap: () => RouteHelper.getOrderListScreen(),
        ),
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'quick_links'.tr,
          style: poppinsMedium.copyWith(
            color: ColorResources.getFooterTextColor(context),
            fontSize: Dimensions.fontSizeExtraLarge,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        _buildFooterLink(
          context,
          title: 'contact_us'.tr,
          onTap: () => RouteHelper.getContactRoute(),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        _buildFooterLink(
          context,
          title: 'privacy_policy'.tr,
          onTap: () => RouteHelper.getPolicyRoute(),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        _buildFooterLink(
          context,
          title: 'terms_and_condition'.tr,
          onTap: () => RouteHelper.getTermsRoute(),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        _buildFooterLink(
          context,
          title: 'about_us'.tr,
          onTap: () => RouteHelper.getAboutUsRoute(),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        _buildFooterLink(
          context,
          title: 'faq'.tr,
          onTap: () => RouteHelper.getFaqRoute(),
        ),
      ],
    );
  }

  Widget _buildFooterLink(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return TextHoverWidget(
      builder: (hovered) {
        return InkWell(
          onTap: onTap,
          child: Text(
            title,
            style: hovered
                ? poppinsMedium.copyWith(
                    color: Theme.of(context).primaryColor,
                  )
                : poppinsRegular.copyWith(
                    color: ColorResources.getFooterTextColor(context),
                    fontSize: Dimensions.fontSizeDefault,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSocialMedia(
    BuildContext context,
    SplashProvider splashProvider,
  ) {
    final isLtr = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    ).isLtr;

    final socialLinks = splashProvider.configModel?.socialMediaLink;
    if (socialLinks == null || socialLinks.isEmpty) {
      return const SizedBox();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'follow_us_on'.tr,
          style: poppinsBold.copyWith(
            color: ColorResources.getFooterTextColor(context),
            fontSize: Dimensions.fontSizeDefault,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(socialLinks.length, (index) {
            String? name = socialLinks[index].name;
            late String icon;
            if (name == 'pinterest') {
              icon = Images.pinterest;
            } else if (name == 'linkedin') {
              icon = Images.linkedInIcon;
            } else if (name == 'facebook') {
              icon = Images.facebook;
            } else if (name == 'twitter') {
              icon = Images.twitter;
            } else if (name == 'instagram') {
              icon = Images.inStaGramIcon;
            } else if (name == 'youtube') {
              icon = Images.youtube;
            } else {
              icon = Images.facebook;
            }

            return InkWell(
              onTap: () {
                if (socialLinks[index].link != null) {
                  _launchURL(socialLinks[index].link!);
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                  left: isLtr && index == 0 ? 0 : 4,
                  right: !isLtr && index == 0 ? 0 : 4,
                ),
                child: TextHoverWidget(
                  builder: (isHover) => Image.asset(
                    icon,
                    height: Dimensions.paddingSizeExtraLarge,
                    width: Dimensions.paddingSizeExtraLarge,
                    fit: BoxFit.contain,
                    color: isHover ? Theme.of(context).primaryColor : null,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCopyright(BuildContext context) {
    final splash = Provider.of<SplashProvider>(context, listen: false);
    final String copyrightText = splash.configModel?.footerCopyright ??
        '${'copyright'.tr} ${splash.configModel?.ecommerceName ?? ''}';

    return Text(
      copyrightText,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      textAlign: TextAlign.center,
      style: poppinsRegular.copyWith(
        color: ColorResources.getFooterTextColor(context),
        fontSize: Dimensions.fontSizeSmall,
      ),
    );
  }
}

Future<void> _launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw 'Could not launch $url';
  }
}

class _FooterFormatter extends StatelessWidget {
  final Widget child;
  final FooterType footerType;
  const _FooterFormatter({required this.child, required this.footerType});

  @override
  Widget build(BuildContext context) {
    final bool showFooter = ResponsiveHelper.isDesktop(context) || kIsWeb;
    return showFooter
        ? (footerType == FooterType.nonSliver
            ? child
            : SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    child,
                  ],
                ),
              ))
        : (footerType == FooterType.sliver
            ? const SliverToBoxAdapter()
            : const SizedBox());
  }
}
