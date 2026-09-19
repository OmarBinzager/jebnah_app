import 'package:flutter/material.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../features/notification/domain/models/notification_model.dart';
import '../../../features/notification/widgets/notification_dialog_widget.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/date_converter_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class NotificationItemWidget extends StatelessWidget {
  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.isTitle,
  });

  final NotificationModel notification;
  final bool isTitle;

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return NotificationDialogWidget(notificationModel: notification);
          },
        );
      },
      hoverColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isTitle
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
                  child: Text(
                    DateConverterHelper.isoStringToLocalDateOnly(
                      notification.createdAt!,
                    ),
                  ),
                )
              : const SizedBox(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        height: 50,
                        width: 50,
                        margin: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.isDesktop(context)
                              ? Dimensions.paddingSizeLarge
                              : 0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CustomImageWidget(
                            placeholder: Images.placeHolder,
                            image:
                                '${splashProvider.baseUrls?.notificationImageUrl}/${notification.image}',
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          notification.title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: poppinsBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        subtitle: Text(
                          notification.description ?? '',
                          style: poppinsLight.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: Dimensions.paddingSizeSmall),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Container(
                  height: 1,
                  color: ColorResources.getGreyColor(
                    context,
                  ).withValues(alpha: .2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
