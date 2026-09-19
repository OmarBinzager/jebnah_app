import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/models/config_model.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../features/refer_and_earn/helper/refer_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/app_localization.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/no_data_widget.dart';
import '../../../common/widgets/not_login_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'refer_hint_widget.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  final List<String> shareItem = [
    'messenger',
    'whatsapp',
    'gmail',
    'viber',
    'share',
  ];
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ConfigModel? configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel;

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(100),
                child: WebAppBarWidget(),
              )
            : null,

        body: _isLoggedIn
            ? configModel != null && configModel.walletStatus!
                  ? Consumer<ProfileProvider>(
                      builder: (context, profileProvider, _) {
                        return profileProvider.userInfoModel != null
                            ? SingleChildScrollView(
                                padding: ResponsiveHelper.isDesktop(context)
                                    ? EdgeInsets.zero
                                    : const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeDefault,
                                        vertical:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),
                                child: Column(
                                  children: [
                                    ResponsiveHelper.isDesktop(context)
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: Dimensions
                                                  .paddingSizeExtraLarge,
                                            ),
                                            child: Center(
                                              child: Text(
                                                "refer_and_earn".tr,
                                                style: poppinsSemiBold.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),

                                    Container(
                                      constraints:
                                          ResponsiveHelper.isDesktop(context)
                                          ? const BoxConstraints()
                                          : BoxConstraints(
                                              maxHeight:
                                                  ResponsiveHelper.isDesktop(
                                                    context,
                                                  )
                                                  ? MediaQuery.of(
                                                      context,
                                                    ).size.height
                                                  : MediaQuery.of(
                                                          context,
                                                        ).size.height *
                                                        0.7,
                                            ),
                                      width: ResponsiveHelper.isDesktop(context)
                                          ? 750
                                          : double.maxFinite,
                                      child:
                                          !ResponsiveHelper.isDesktop(context)
                                          ? SingleChildScrollView(
                                              child: DetailsView(
                                                size: size,
                                                shareItem: shareItem,
                                                hintList:
                                                    profileProvider.hintList,
                                              ),
                                            )
                                          : DetailsView(
                                              size: size,
                                              shareItem: shareItem,
                                              hintList:
                                                  profileProvider.hintList,
                                            ),
                                    ),

                                    const FooterWebWidget(
                                      footerType: FooterType.nonSliver,
                                    ),
                                  ],
                                ),
                              )
                            : CustomLoaderWidget(
                                color: Theme.of(context).primaryColor,
                              );
                      },
                    )
                  : NoDataWidget(title: getTranslated('not_found', context))
            : const NotLoggedInWidget(),
      ),
    );
  }
}

// expandableContent: ResponsiveHelper.isDesktop(context)
//     ? const SizedBox() : ReferHintWidget(hintList: hintList),

class DetailsView extends StatelessWidget {
  const DetailsView({
    super.key,
    required Size size,
    required this.shareItem,
    required this.hintList,
  }) : _size = size;

  final Size _size;
  final List<String> shareItem;
  final List<String?> hintList;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        return profileProvider.userInfoModel != null
            ? Column(
                children: [
                  Image.asset(
                    Images.referBanner,
                    height: _size.height * 0.3,
                    width: _size.width * 0.7,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text(
                    getTranslated('invite_friend_and_businesses', context),
                    textAlign: TextAlign.center,
                    style: poppinsMedium.copyWith(
                      fontSize: Dimensions.fontSizeOverLarge,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    getTranslated('copy_your_code', context),
                    textAlign: TextAlign.center,
                    style: poppinsRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Text(
                    getTranslated('your_personal_code', context),
                    textAlign: TextAlign.center,
                    style: poppinsRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      fontWeight: FontWeight.w200,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      padding: const EdgeInsets.all(4),
                      radius: const Radius.circular(Dimensions.radiusSizeLarge),
                      dashPattern: const [5, 5],
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.5),
                      strokeWidth: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                            ),
                            child: Text(
                              profileProvider.userInfoModel!.referCode ?? '',
                              style: poppinsRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            if (profileProvider.userInfoModel!.referCode !=
                                    null &&
                                profileProvider.userInfoModel!.referCode !=
                                    '') {
                              Clipboard.setData(
                                ClipboardData(
                                  text:
                                      '${profileProvider.userInfoModel != null ? profileProvider.userInfoModel!.referCode : ''}',
                                ),
                              );
                              showCustomSnackBarHelper(
                                getTranslated('referral_code_copied', context),
                                isError: false,
                              );
                            }
                          },
                          child: Container(
                            width: 85,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: FittedBox(
                              child: Text(
                                getTranslated('copy', context),
                                style: poppinsRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Text(
                    getTranslated('or_share', context),
                    style: poppinsRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => SharePlus.instance.share(
                      ShareParams(
                        title: ReferHelper.getSignUpLink(
                          profileProvider.userInfoModel!.referCode!,
                        ),
                        uri: Uri.tryParse(
                          '${AppConstants.webHostUrl}${RouteHelper.createAccount}?referral_code=${profileProvider.userInfoModel?.referCode ?? ''}',
                        ),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Image.asset(
                        Images.getShareIcon('share'),
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),

                  if (ResponsiveHelper.isDesktop(context))
                    Column(
                      children: [
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        ReferHintWidget(hintList: hintList),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ],
                    ),
                ],
              )
            : const SizedBox();
      },
    );
  }
}
