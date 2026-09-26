import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../localization/app_localization.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_button_widget.dart';
import '../../../helper/custom_snackbar_helper.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Images.update,
                  width: MediaQuery.of(context).size.height * 0.4,
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                Text(
                  getTranslated('your_app_is_deprecated', context),
                  style: poppinsRegular.copyWith(
                    fontSize: MediaQuery.of(context).size.height * 0.0175,
                    color: Theme.of(context).disabledColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                CustomButtonWidget(
                  buttonText: getTranslated('update_now', context),
                  onPressed: () async {
                    String? appUrl = 'https://google.com';
                    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
                      appUrl =
                          splashProvider.configModel!.playStoreConfig!.link;
                    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
                      appUrl = splashProvider.configModel!.appStoreConfig!.link;
                    }
                    if (await canLaunchUrl(Uri.parse(appUrl!))) {
                      launchUrl(
                        Uri.parse(appUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      showCustomSnackBarHelper(
                        '${'can_not_launch'.tr} $appUrl',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
