import 'package:flutter/material.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return Center(
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return SizedBox(
            width: Dimensions.webScreenWidth,
            child: ResponsiveHelper.isDesktop(context)
                ? Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 150,
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.5),
                          ),

                          Positioned(
                            left: 30,
                            top: 45,
                            child: Container(
                              height: 180,
                              width: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    blurRadius: 22,
                                    offset: const Offset(0, 8.8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: CustomImageWidget(
                                  placeholder: Images.placeHolder,
                                  height: 170,
                                  width: 170,
                                  fit: BoxFit.cover,
                                  image:
                                      '${splashProvider.baseUrls?.customerImageUrl}/${profileProvider.userInfoModel?.image}',
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: -10,
                            right: 10,
                            child: InkWell(
                              onTap: () => RouteHelper.getProfileEditRoute(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.edit,
                                      size: Dimensions.paddingSizeDefault,
                                      color: Colors.white,
                                    ),

                                    Text(
                                      getTranslated('edit', context),
                                      style: poppinsMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 100),
                    ],
                  )
                : Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ColorResources.getGreyColor(context),
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: profileProvider.file == null
                                  ? CustomImageWidget(
                                      placeholder: Images.placeHolder,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      image:
                                          '${splashProvider.baseUrls?.customerImageUrl}/${profileProvider.userInfoModel?.image}',
                                    )
                                  : Image.file(
                                      profileProvider.file!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),

                          Positioned(
                            right: -10,
                            child: TextButton(
                              onPressed: () =>
                                  RouteHelper.getProfileEditRoute(),
                              child: Text(
                                getTranslated('edit', context),
                                style: poppinsMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
