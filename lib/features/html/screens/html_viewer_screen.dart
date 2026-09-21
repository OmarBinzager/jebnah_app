import 'package:flutter/material.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/enums/html_type_enum.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/app_localization.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../common/models/config_model.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HtmlViewerScreen extends StatelessWidget {
  final HtmlType htmlType;
  const HtmlViewerScreen({super.key, required this.htmlType});

  String _resolvePolicyImageUrl(TermsAndConditions? policy) {
    if (policy == null) return '';

    String raw = (policy.backgroundImageUrl ?? '').trim();
    if (raw.isEmpty) {
      raw = (policy.backgroundImage ?? '').trim();
    }
    if (raw.isEmpty) return '';

    // If it's already a full URL, fix the missing storage/app/public path
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      if (raw.contains('/storage/business-settings/page-setup/')) {
        return raw.replaceAll(
          '/storage/business-settings/page-setup/',
          '/storage/app/public/business-settings/page-setup/',
        );
      }
      return raw;
    }

    String clean = raw.startsWith('/') ? raw.substring(1) : raw;
    if (clean.contains('storage/business-settings/page-setup/')) {
      clean = clean.replaceAll(
        'storage/business-settings/page-setup/',
        'storage/app/public/business-settings/page-setup/',
      );
    }

    if (clean.contains('storage/app/public/business-settings/page-setup/')) {
      return '${AppConstants.baseUrl}/$clean';
    }

    return '${AppConstants.baseUrl}/storage/app/public/business-settings/page-setup/$clean';
  }

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel;
    String data = 'no_result_found';
    String appBarText = '';
    TermsAndConditions? selectedPolicy;

    switch (htmlType) {
      case HtmlType.termsAndCondition:
        selectedPolicy = configModel?.termsAndConditions;
        data = selectedPolicy?.description ?? '';
        appBarText = 'terms_and_condition';
        break;
      case HtmlType.aboutUs:
        selectedPolicy = configModel?.aboutUs;
        data = selectedPolicy?.description ?? '';
        appBarText = 'about_us';
        break;
      case HtmlType.privacyPolicy:
        selectedPolicy = configModel?.privacyPolicy;
        data = selectedPolicy?.description ?? '';
        appBarText = 'privacy_policy';
        break;
      case HtmlType.faq:
        selectedPolicy = configModel?.faq;
        data = selectedPolicy?.description ?? '';
        appBarText = 'faq';
        break;
      case HtmlType.cancellationPolicy:
        selectedPolicy = configModel?.cancellationPolicy;
        data = selectedPolicy?.description ?? '';
        appBarText = 'cancellation_policy';
        break;
      case HtmlType.refundPolicy:
        selectedPolicy = configModel?.refundPolicy;
        data = selectedPolicy?.description ?? '';
        appBarText = 'refund_policy';
        break;
      case HtmlType.returnPolicy:
        selectedPolicy = configModel?.returnPolicy;
        data = selectedPolicy?.description ?? '';
        appBarText = 'return_policy';
        break;
    }

    String imageUrl = _resolvePolicyImageUrl(selectedPolicy);
    final bool hasValidBannerImage = imageUrl.trim().isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    if (data.isNotEmpty) {
      data = data.replaceAll('href=', 'target="_blank" href=');
    }

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : null,
        body: SingleChildScrollView(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: ResponsiveHelper.isDesktop(context)
                      ? MediaQuery.of(context).size.height - 400
                      : MediaQuery.of(context).size.height,
                ),
                child: Container(
                  width: 1170,
                  color: Theme.of(context).canvasColor,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ResponsiveHelper.isDesktop(context)
                            ? Text(
                                appBarText.tr,
                                style: poppinsBold.copyWith(
                                  fontSize: 28,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        if (hasValidBannerImage) ...[
                          SizedBox(
                            height: ResponsiveHelper.isMobilePhone() ? 120 : 180,
                            width: Dimensions.webScreenWidth,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                Dimensions.paddingSizeSmall,
                              ),
                              child: CustomImageWidget(
                                image: imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                        ],

                        Padding(
                          padding: ResponsiveHelper.isDesktop(context)
                              ? const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                  vertical: Dimensions.paddingSizeSmall,
                                )
                              : const EdgeInsets.all(0.0),
                          child: HtmlWidget(
                            data,
                            key: Key(htmlType.toString()),
                            textStyle: poppinsRegular.copyWith(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                            onTapUrl: (String url) {
                              return launchUrlString(url);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const FooterWebWidget(footerType: FooterType.nonSliver),
            ],
          ),
        ),
      ),
    );
  }
}
