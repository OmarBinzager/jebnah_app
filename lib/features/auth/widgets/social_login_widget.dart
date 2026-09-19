import 'package:flutter/material.dart';
import '../../../common/models/config_model.dart';
import '../../../common/widgets/custom_alert_dialog_widget.dart';
import '../../../features/auth/domain/models/social_login_model.dart';
import '../../../features/auth/enum/social_login_options_enum.dart';
import '../../../features/auth/widgets/existing_account_bottom_sheet.dart';
import '../../../features/profile/domain/models/userinfo_model.dart';
import '../../../helper/auth_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/app_constants.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialLoginWidget extends StatefulWidget {
  const SocialLoginWidget({super.key});

  @override
  State<SocialLoginWidget> createState() => _SocialLoginWidgetState();
}

class _SocialLoginWidgetState extends State<SocialLoginWidget> {
  SocialLoginModel socialLogin = SocialLoginModel();
  TextEditingController phoneController = TextEditingController();
  FocusNode focusNode = FocusNode();

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
    final ConfigModel? configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.countSocialLoginOptions == 1) {
          return Row(
            children: [
              if (AuthHelper.isGoogleLoginEnable(configModel))
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final SocialLoginModel? socialLoginModel =
                          await authProvider.googleLogin();

                      if (socialLoginModel != null) {
                        authProvider.socialLogin(socialLoginModel, route);
                      }
                    },
                    child: SocialLoginButtonWidget(
                      text: getTranslated('continue_with_google', context),
                      image: Images.google,
                    ),
                  ),
                ),

              if (AuthHelper.isFacebookLoginEnable(configModel))
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final SocialLoginModel? socialLoginModel =
                          await authProvider.facebookLogin(context);

                      if (socialLoginModel != null) {
                        authProvider.socialLogin(socialLoginModel, route);
                      }
                    },
                    child: SocialLoginButtonWidget(
                      text: getTranslated('continue_with_facebook', context),
                      image: Images.facebook,
                    ),
                  ),
                ),

              if (AuthHelper.isAppleLoginEnable(configModel))
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final credential =
                          await SignInWithApple.getAppleIDCredential(
                            scopes: [
                              AppleIDAuthorizationScopes.email,
                              AppleIDAuthorizationScopes.fullName,
                            ],
                            webAuthenticationOptions: WebAuthenticationOptions(
                              clientId: '${configModel?.appleLogin?.clientId}',
                              redirectUri: Uri.parse(AppConstants.baseUrl),
                            ),
                          );
                      authProvider.socialLogin(
                        SocialLoginModel(
                          email: credential.email,
                          token: credential.authorizationCode,
                          uniqueId: credential.authorizationCode,
                          medium: SocialLoginOptionsEnum.apple.name,
                          name: credential.givenName,
                        ),
                        route,
                      );
                    },
                    child: SocialLoginButtonWidget(
                      text: getTranslated('continue_with_apple', context),
                      image: Images.appleLogo,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
            ],
          );
        } else if (authProvider.countSocialLoginOptions == 2) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (AuthHelper.isGoogleLoginEnable(configModel)) ...[
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final SocialLoginModel? socialLoginModel =
                          await authProvider.googleLogin();

                      if (socialLoginModel != null) {
                        authProvider.socialLogin(socialLoginModel, route);
                      }
                    },
                    child: SocialLoginButtonWidget(
                      text: getTranslated('google', context),
                      image: Images.google,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
              ],

              if (AuthHelper.isFacebookLoginEnable(configModel)) ...[
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final SocialLoginModel? socialLoginModel =
                          await authProvider.facebookLogin(context);

                      if (socialLoginModel != null) {
                        authProvider.socialLogin(socialLoginModel, route);
                      }
                    },
                    child: SocialLoginButtonWidget(
                      text: getTranslated('facebook', context),
                      image: Images.facebook,
                    ),
                  ),
                ),
                AuthHelper.isAppleLoginEnable(configModel)
                    ? const SizedBox(width: Dimensions.paddingSizeDefault)
                    : const SizedBox.shrink(),
              ],

              if (AuthHelper.isAppleLoginEnable(configModel)) ...[
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final credential =
                          await SignInWithApple.getAppleIDCredential(
                            scopes: [
                              AppleIDAuthorizationScopes.email,
                              AppleIDAuthorizationScopes.fullName,
                            ],
                            webAuthenticationOptions: WebAuthenticationOptions(
                              clientId: '${configModel?.appleLogin?.clientId}',
                              redirectUri: Uri.parse(AppConstants.baseUrl),
                            ),
                          );
                      authProvider.socialLogin(
                        SocialLoginModel(
                          email: credential.email,
                          token: credential.authorizationCode,
                          uniqueId: credential.authorizationCode,
                          medium: SocialLoginOptionsEnum.apple.name,
                          name: credential.givenName,
                        ),
                        route,
                      );
                    },
                    child: SocialLoginButtonWidget(
                      text: getTranslated('apple', context),
                      image: Images.appleLogo,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ],
          );
        } else if (authProvider.countSocialLoginOptions == 3) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (AuthHelper.isGoogleLoginEnable(configModel)) ...[
                InkWell(
                  onTap: () async {
                    final SocialLoginModel? socialLoginModel =
                        await authProvider.googleLogin();

                    if (socialLoginModel != null) {
                      authProvider.socialLogin(socialLoginModel, route);
                    }
                  },
                  child: const SocialLoginButtonWidget(
                    image: Images.google,
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeLarge),
              ],

              if (AuthHelper.isFacebookLoginEnable(configModel)) ...[
                InkWell(
                  onTap: () async {
                    final SocialLoginModel? socialLoginModel =
                        await authProvider.facebookLogin(context);

                    if (socialLoginModel != null) {
                      authProvider.socialLogin(socialLoginModel, route);
                    }
                  },
                  child: const SocialLoginButtonWidget(
                    image: Images.facebook,
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeLarge),
              ],

              if (AuthHelper.isAppleLoginEnable(configModel)) ...[
                InkWell(
                  onTap: () async {
                    final credential =
                        await SignInWithApple.getAppleIDCredential(
                          scopes: [
                            AppleIDAuthorizationScopes.email,
                            AppleIDAuthorizationScopes.fullName,
                          ],
                          webAuthenticationOptions: WebAuthenticationOptions(
                            clientId: '${configModel?.appleLogin?.clientId}',
                            redirectUri: Uri.parse(AppConstants.baseUrl),
                          ),
                        );
                    authProvider.socialLogin(
                      SocialLoginModel(
                        email: credential.email,
                        token: credential.authorizationCode,
                        uniqueId: credential.authorizationCode,
                        medium: SocialLoginOptionsEnum.apple.name,
                        name: credential.givenName,
                      ),
                      route,
                    );
                  },
                  child: SocialLoginButtonWidget(
                    image: Images.appleLogo,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  ),
                ),
              ],
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class SocialLoginButtonWidget extends StatelessWidget {
  final String? text;
  final String image;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  const SocialLoginButtonWidget({
    super.key,
    this.text,
    required this.image,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            color: color,
            height: ResponsiveHelper.isDesktop(context)
                ? 25
                : ResponsiveHelper.isTab(context)
                ? 20
                : 15,
            width: ResponsiveHelper.isDesktop(context)
                ? 25
                : ResponsiveHelper.isTab(context)
                ? 20
                : 15,
          ),

          if (text != null) ...[
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              text!,
              style: poppinsSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
