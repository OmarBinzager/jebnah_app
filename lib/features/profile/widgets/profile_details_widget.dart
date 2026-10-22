import 'package:flutter/material.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class ProfileDetailsWidget extends StatelessWidget {
  const ProfileDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        if (profileProvider.isLoading || profileProvider.userInfoModel == null) {
          return CustomLoaderWidget(color: Theme.of(context).primaryColor);
        }
        final userInfo = profileProvider.userInfoModel!;
        return Center(
          child: Container(
            width: Dimensions.webScreenWidth * 0.7,
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveHelper.isDesktop(context)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated('name', context),
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${userInfo.fName ?? ''} ${userInfo.lName ?? ''}',
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                          const Divider(),
                        ],
                      )
                    : Center(
                        child: Text(
                          '${userInfo.fName ?? ''} ${userInfo.lName ?? ''}',
                          style: poppinsMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                          ),
                        ),
                      ),
                const SizedBox(height: 30),

                // for first name section
                Text(
                  getTranslated('mobile_number', context),
                  style: poppinsRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(
                      context,
                    ).hintColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  userInfo.phone ?? '',
                  style: poppinsRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                const Divider(),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                Text(
                  getTranslated('email', context),
                  style: poppinsRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(
                      context,
                    ).hintColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  userInfo.email ?? '',
                  style: poppinsRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                const Divider(),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              ],
            ),
          ),
        );
      },
    );
  }
}
