import 'package:flutter/material.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/models/config_model.dart';
import '../../../common/widgets/custom_alert_dialog_widget.dart';
import '../../../common/widgets/custom_asset_image_widget.dart';
import '../../../common/widgets/custom_pop_scope_widget.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../features/auth/domain/models/social_login_model.dart';
import '../../../features/auth/enum/social_login_options_enum.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/widgets/existing_account_bottom_sheet.dart';
import '../../../features/profile/domain/models/userinfo_model.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/auth_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class OnlySocialLoginWidget extends StatefulWidget {
  const OnlySocialLoginWidget({super.key});

  @override
  State<OnlySocialLoginWidget> createState() => _OnlySocialLoginWidgetState();
}

class _OnlySocialLoginWidgetState extends State<OnlySocialLoginWidget> {
  void route(
    bool isRoute,
    String? token,
    String? errorMessage,
    String? tempToken,
    UserInfoModel? userInfoModel,
    String? socialLoginMedium,
    String? email,
    String? name,
  ) async {
    if (isRoute) {
      if (token != null) {
        RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
      } else if (tempToken != null) {
        RouteHelper.getOtpRegistration(
          tempToken,
          email ?? '',
          userName: name ?? '',
          action: RouteAction.pushNamedAndRemoveUntil,
        );
      } else if (userInfoModel != null) {
        ResponsiveHelper().showDialogOrBottomSheet(
          context,
          CustomAlertDialogWidget(
            // width: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.width * 0.3 : null,
            child: ExistingAccountBottomSheet(
              userInfoModel: userInfoModel,
              socialLoginMedium: socialLoginMedium!,
              socialUserName: name ?? '',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? ''),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? ''),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ConfigModel? configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel;

    return CustomPopScopeWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : null,
        body: SafeArea(
          child: Center(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: size.width > 700 ? 450 : size.width,
                          margin: const EdgeInsets.only(
                            top: Dimensions.paddingSizeLarge,
                          ),
                          padding: size.width > 700
                              ? const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault,
                                )
                              : null,
                          decoration: size.width > 700
                              ? BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color!
                                          .withValues(alpha: 0.07),
                                      blurRadius: 30,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                )
                              : null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: ResponsiveHelper.isDesktop(context)
                                    ? size.height * 0.03
                                    : size.height * 0.05,
                              ),

                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: CustomAssetImageWidget(
                                  Images.appLogo,
                                  height: ResponsiveHelper.isDesktop(context)
                                      ? MediaQuery.of(context).size.height *
                                            0.15
                                      : MediaQuery.of(context).size.height /
                                            4.5,
                                  fit: BoxFit.scaleDown,
                                ),
                              ),

                              SizedBox(height: size.height * 0.01),

                              Text(
                                getTranslated('welcome_to_gro_fresh', context),
                                style: poppinsRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),

                              if (AuthHelper.isGoogleLoginEnable(
                                configModel,
                              )) ...[
                                Row(
                                  children: [
                                    Expanded(child: Container()),

                                    Expanded(
                                      flex: 4,
                                      child: Consumer<AuthProvider>(
                                        builder: (context, authProvider, child) {
                                          return InkWell(
                                            onTap: () async {
                                              final SocialLoginModel?
                                              socialLoginModel =
                                                  await authProvider
                                                      .googleLogin();

                                              if (socialLoginModel != null) {
                                                authProvider.socialLogin(
                                                  socialLoginModel,
                                                  route,
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: Dimensions
                                                        .paddingSizeDefault,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .hintColor
                                                    .withValues(alpha: 0.08),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions
                                                          .radiusSizeSmall,
                                                    ),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.1),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    Images.google,
                                                    height:
                                                        ResponsiveHelper.isDesktop(
                                                          context,
                                                        )
                                                        ? 20
                                                        : ResponsiveHelper.isTab(
                                                            context,
                                                          )
                                                        ? 20
                                                        : 15,
                                                    width:
                                                        ResponsiveHelper.isDesktop(
                                                          context,
                                                        )
                                                        ? 20
                                                        : ResponsiveHelper.isTab(
                                                            context,
                                                          )
                                                        ? 20
                                                        : 15,
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),

                                                  Text(
                                                    getTranslated(
                                                      "continue_with_google",
                                                      context,
                                                    ),
                                                    style: poppinsSemiBold
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.color,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    Expanded(child: Container()),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                              ],

                              if (AuthHelper.isFacebookLoginEnable(
                                configModel,
                              )) ...[
                                Row(
                                  children: [
                                    Expanded(child: Container()),

                                    Expanded(
                                      flex: 4,
                                      child: Consumer<AuthProvider>(
                                        builder: (context, authProvider, child) {
                                          return InkWell(
                                            onTap: () async {
                                              final SocialLoginModel?
                                              socialLoginModel =
                                                  await authProvider
                                                      .facebookLogin(context);

                                              if (socialLoginModel != null) {
                                                authProvider.socialLogin(
                                                  socialLoginModel,
                                                  route,
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: Dimensions
                                                        .paddingSizeDefault,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .hintColor
                                                    .withValues(alpha: 0.08),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions
                                                          .radiusSizeSmall,
                                                    ),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.1),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    Images.facebook,
                                                    height:
                                                        ResponsiveHelper.isDesktop(
                                                          context,
                                                        )
                                                        ? 20
                                                        : ResponsiveHelper.isTab(
                                                            context,
                                                          )
                                                        ? 20
                                                        : 15,
                                                    width:
                                                        ResponsiveHelper.isDesktop(
                                                          context,
                                                        )
                                                        ? 20
                                                        : ResponsiveHelper.isTab(
                                                            context,
                                                          )
                                                        ? 20
                                                        : 15,
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),

                                                  Text(
                                                    getTranslated(
                                                      "continue_with_facebook",
                                                      context,
                                                    ),
                                                    style: poppinsSemiBold
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.color,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    Expanded(child: Container()),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                              ],

                              if (AuthHelper.isAppleLoginEnable(
                                configModel,
                              )) ...[
                                Row(
                                  children: [
                                    Expanded(child: Container()),

                                    Expanded(
                                      flex: 4,
                                      child: Consumer<AuthProvider>(
                                        builder: (context, authProvider, child) {
                                          return InkWell(
                                            onTap: () async {
                                              final credential =
                                                  await SignInWithApple.getAppleIDCredential(
                                                    scopes: [
                                                      AppleIDAuthorizationScopes
                                                          .email,
                                                      AppleIDAuthorizationScopes
                                                          .fullName,
                                                    ],
                                                    webAuthenticationOptions:
                                                        WebAuthenticationOptions(
                                                          clientId:
                                                              '${configModel?.appleLogin?.clientId}',
                                                          redirectUri:
                                                              Uri.parse(
                                                                AppConstants
                                                                    .baseUrl,
                                                              ),
                                                        ),
                                                  );
                                              authProvider.socialLogin(
                                                SocialLoginModel(
                                                  email: credential.email,
                                                  token: credential
                                                      .authorizationCode,
                                                  uniqueId: credential
                                                      .authorizationCode,
                                                  medium: SocialLoginOptionsEnum
                                                      .apple
                                                      .name,
                                                ),
                                                route,
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: Dimensions
                                                        .paddingSizeDefault,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .hintColor
                                                    .withValues(alpha: 0.08),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions
                                                          .radiusSizeSmall,
                                                    ),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.1),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    Images.appleLogo,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                                    height:
                                                        ResponsiveHelper.isDesktop(
                                                          context,
                                                        )
                                                        ? 20
                                                        : ResponsiveHelper.isTab(
                                                            context,
                                                          )
                                                        ? 20
                                                        : 15,
                                                    width:
                                                        ResponsiveHelper.isDesktop(
                                                          context,
                                                        )
                                                        ? 20
                                                        : ResponsiveHelper.isTab(
                                                            context,
                                                          )
                                                        ? 20
                                                        : 15,
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),

                                                  Text(
                                                    getTranslated(
                                                      "continue_with_apple",
                                                      context,
                                                    ),
                                                    style: poppinsSemiBold
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.color,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    Expanded(child: Container()),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                              ],

                              if (configModel?.isGuestCheckout == true &&
                                  !Navigator.canPop(context)) ...[
                                Center(
                                  child: Text(
                                    getTranslated('or', context),
                                    style: poppinsRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                ///login
                                Center(
                                  child: InkWell(
                                    onTap: () => RouteHelper.getMainRoute(
                                      action:
                                          RouteAction.pushNamedAndRemoveUntil,
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '${getTranslated('continue_as_a', context)} ',
                                            style: poppinsRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                          ),

                                          TextSpan(
                                            text: getTranslated(
                                              'guest',
                                              context,
                                            ),
                                            style: poppinsRegular.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.03),
                              ],
                            ],
                          ),
                        ),
                      ),

                      if (ResponsiveHelper.isDesktop(context))
                        const SizedBox(height: 50),
                    ],
                  ),
                ),

                if (ResponsiveHelper.isDesktop(context))
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(height: Dimensions.paddingSizeLarge),

                        FooterWebWidget(footerType: FooterType.nonSliver),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
