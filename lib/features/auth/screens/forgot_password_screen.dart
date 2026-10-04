import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/models/config_model.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../features/auth/enum/from_page_enum.dart';
import '../../../features/auth/enum/verification_type_enum.dart';
import '../../../features/auth/providers/verification_provider.dart';
import '../../../helper/auth_helper.dart';
import '../../../helper/email_checker_helper.dart';
import '../../../helper/phone_number_checker_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../common/widgets/custom_app_bar_widget.dart';
import '../../../common/widgets/custom_button_widget.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../../../common/widgets/custom_text_field_widget.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  String? _countryDialCode;

  @override
  void initState() {
    super.initState();
    try {
      final config =
          Provider.of<SplashProvider>(context, listen: false).configModel;
      if (config?.country != null) {
        _countryDialCode =
            CountryCode.fromCountryCode(config!.country!).dialCode;
      }
    } catch (_) {}
    _countryDialCode ??= '+967';
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    final ConfigModel configModel = Provider.of<SplashProvider>(
      context,
      listen: false,
    ).configModel!;
    double width = MediaQuery.of(context).size.width;

    String forgotPasswordMethod = "both";

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar:
            (ResponsiveHelper.isDesktop(context)
                    ? const PreferredSize(
                        preferredSize: Size.fromHeight(120),
                        child: WebAppBarWidget(),
                      )
                    : CustomAppBarWidget(
                        title: getTranslated('forgot_password', context),
                      ))
                as PreferredSizeWidget?,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  width: !ResponsiveHelper.isMobile() ? 700 : width,
                  padding: !ResponsiveHelper.isMobile()
                      ? const EdgeInsets.all(Dimensions.paddingSizeDefault)
                      : null,
                  margin: !ResponsiveHelper.isMobile()
                      ? const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeLarge,
                        )
                      : null,
                  decoration: !ResponsiveHelper.isMobile()
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
                  child: Consumer<VerificationProvider>(
                    builder: (context, verificationProvider, child) {
                      return Column(
                        children: [
                          const SizedBox(height: 55),
                          Image.asset(
                            Images.closeLock,
                            width: 142,
                            height: 142,
                            color: Theme.of(context).primaryColor,
                          ),

                          Padding(
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeLarge,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 80),

                                (forgotPasswordMethod == "both")
                                    ? Selector<AuthProvider, bool>(
                                        selector: (context, authProvider) =>
                                            authProvider.isNumberLogin,
                                        builder: (context, isNumberLogin, child) {
                                          return CustomTextFieldWidget(
                                            countryDialCode: isNumberLogin
                                                ? _countryDialCode
                                                : null,
                                            onCountryChanged:
                                                (CountryCode value) =>
                                                    _countryDialCode =
                                                        value.dialCode,
                                            onChanged: (String text) =>
                                                AuthHelper.identifyEmailOrNumber(
                                                  text,
                                                  authProvider,
                                                ),
                                            hintText: getTranslated(
                                              'enter_email_phone_number',
                                              context,
                                            ),
                                            title: getTranslated(
                                              'email_phone',
                                              context,
                                            ),
                                            isShowBorder: true,
                                            controller: _emailOrPhoneController,
                                            inputType:
                                                TextInputType.emailAddress,
                                          );
                                        },
                                      )
                                    : (forgotPasswordMethod == "phone")
                                    ? Selector<AuthProvider, bool>(
                                        selector: (context, authProvider) =>
                                            authProvider.isNumberLogin,
                                        builder: (context, isNumberLogin, child) {
                                          return CustomTextFieldWidget(
                                            countryDialCode: _countryDialCode,
                                            onCountryChanged:
                                                (CountryCode value) =>
                                                    _countryDialCode =
                                                        value.dialCode,
                                            onChanged: (String text) =>
                                                AuthHelper.identifyEmailOrNumber(
                                                  text,
                                                  authProvider,
                                                ),
                                            hintText: getTranslated(
                                              'number_hint',
                                              context,
                                            ),
                                            title: getTranslated(
                                              'phone',
                                              context,
                                            ),
                                            isShowBorder: true,
                                            controller: _emailOrPhoneController,
                                            inputType: TextInputType.phone,
                                          );
                                        },
                                      )
                                    : Selector<AuthProvider, bool>(
                                        selector: (context, authProvider) =>
                                            authProvider.isNumberLogin,
                                        builder:
                                            (context, isNumberLogin, child) {
                                              return CustomTextFieldWidget(
                                                hintText: getTranslated(
                                                  'demo_gmail',
                                                  context,
                                                ),
                                                title: getTranslated(
                                                  'email',
                                                  context,
                                                ),
                                                isShowBorder: true,
                                                controller:
                                                    _emailOrPhoneController,
                                                inputType:
                                                    TextInputType.emailAddress,
                                              );
                                            },
                                      ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge,
                                ),

                                SizedBox(
                                  width: Dimensions.webScreenWidth,
                                  child: CustomButtonWidget(
                                    isLoading:
                                        verificationProvider.isLoading ||
                                        authProvider.isLoading,
                                    buttonText: getTranslated('send', context),
                                    onPressed: () {
                                      String rawInput =
                                          _emailOrPhoneController.text.trim();
                                      bool isNumber =
                                          EmailCheckerHelper.isNotValid(
                                            rawInput,
                                          );
                                      String userInput = rawInput;
                                      bool isNumberValid = true;

                                      if (isNumber) {
                                        String cleanNumber = rawInput
                                            .replaceAll(' ', '')
                                            .replaceAll('-', '');
                                        if (cleanNumber.startsWith('+')) {
                                          userInput = cleanNumber;
                                        } else if (_countryDialCode != null &&
                                            cleanNumber.startsWith(
                                              _countryDialCode!.replaceAll(
                                                '+',
                                                '',
                                              ),
                                            )) {
                                          userInput = '+$cleanNumber';
                                        } else {
                                          if (cleanNumber.startsWith('0')) {
                                           cleanNumber =
                                               cleanNumber.substring(1);
                                          }
                                          userInput =
                                              '${_countryDialCode ?? ''}$cleanNumber';
                                        }
                                        isNumberValid =
                                            PhoneNumberCheckerHelper
                                                .isPhoneValidWithCountryCode(
                                                  userInput,
                                                ) ||
                                            PhoneNumberCheckerHelper
                                                .isValidPhone(cleanNumber);
                                      }

                                      if (_emailOrPhoneController
                                              .text
                                              .isEmpty &&
                                          forgotPasswordMethod == "both") {
                                        showCustomSnackBarHelper(
                                          getTranslated(
                                            'enter_email_or_phone',
                                            context,
                                          ),
                                        );
                                      } else if (_emailOrPhoneController
                                              .text
                                              .isEmpty &&
                                          forgotPasswordMethod == "email") {
                                        showCustomSnackBarHelper(
                                          getTranslated(
                                            'enter_email_address',
                                            context,
                                          ),
                                        );
                                      } else if (_emailOrPhoneController
                                              .text
                                              .isNotEmpty &&
                                          forgotPasswordMethod == "email" &&
                                          EmailCheckerHelper.isNotValid(
                                            _emailOrPhoneController.text,
                                          )) {
                                        showCustomSnackBarHelper(
                                          getTranslated(
                                            'enter_valid_email',
                                            context,
                                          ),
                                        );
                                      } else if (isNumber &&
                                          !isNumberValid &&
                                          (forgotPasswordMethod == "both" ||
                                              forgotPasswordMethod ==
                                                  "phone")) {
                                        showCustomSnackBarHelper(
                                          getTranslated(
                                            'invalid_phone_number',
                                            context,
                                          ),
                                        );
                                      } else {
                                        if (AuthHelper.isFirebaseVerificationEnable(
                                              configModel,
                                            ) &&
                                            isNumber) {
                                          verificationProvider
                                              .firebaseVerifyPhoneNumber(
                                                context,
                                                userInput,
                                                FromPage.forget.name,
                                                isForgetPassword: true,
                                              );
                                        } else {
                                          authProvider
                                              .forgetPassword(
                                                userInput,
                                                isNumber
                                                    ? VerificationType
                                                          .phone
                                                          .name
                                                    : VerificationType
                                                          .email
                                                          .name,
                                              )
                                              .then((value) {
                                                if (value.isSuccess) {
                                                  RouteHelper.getVerifyRoute(
                                                    userInput,
                                                    FromPage.forget.name,
                                                  );
                                                } else {
                                                  showCustomSnackBarHelper(
                                                    value.message!,
                                                  );
                                                }
                                              });
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
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
