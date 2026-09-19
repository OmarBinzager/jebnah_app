import 'package:flutter/material.dart';
import '../../../../features/menu/domain/models/menu_model.dart';
import '../../../../helper/route_helper.dart';
import '../../../../localization/language_constraints.dart';
import '../../../../main.dart';
import '../../../../utill/dimensions.dart';
import '../../../../utill/images.dart';
import '../../../../utill/styles.dart';
import '../../../../common/widgets/text_hover_widget.dart';
import '../../../../features/menu/widgets/sign_out_dialog_widget.dart';

class ProfileHoverWidget extends StatefulWidget {
  final String? currentRoute;
  const ProfileHoverWidget({super.key, this.currentRoute});

  @override
  State<ProfileHoverWidget> createState() => _ProfileHoverWidgetState();
}

class _ProfileHoverWidgetState extends State<ProfileHoverWidget> {
  bool isExited = false;

  @override
  Widget build(BuildContext context) {
    List<MenuModel> list = [
      MenuModel(
        icon: Images.profile,
        title: getTranslated('profile', context),
        route: () => RouteHelper.getProfileScreen(),
      ),
      MenuModel(
        icon: Images.order,
        title: getTranslated('my_orders', context),
        route: () => RouteHelper.getOrderListScreen(),
      ),
      MenuModel(
        icon: Images.profile,
        title: getTranslated('log_out', context),
        route: () {
          Navigator.pop(context);

          Future.delayed(
            const Duration(seconds: 0),
            () => showDialog(
              context: Get.context!,
              barrierDismissible: false,
              builder: (context) => const SignOutDialogWidget(),
            ),
          );
        },
      ),
    ];

    return MouseRegion(
      onExit: isExited ? null : (_) => Navigator.of(context).pop(),
      child: Container(
        color: Theme.of(context).cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list
              .map(
                (item) =>
                    widget.currentRoute == _checkRoutes(context, item.title)
                    ? const SizedBox()
                    : InkWell(
                        onTap: () {
                          setState(() {
                            isExited = true;
                          });

                          item.route();
                        },
                        child: Column(
                          children: [
                            TextHoverWidget(
                              builder: (isHover) => Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeExtraSmall,
                                ),
                                decoration: BoxDecoration(
                                  color: isHover
                                      ? Theme.of(context).focusColor
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),
                                      child: Text(
                                        item.title ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: poppinsRegular,
                                      ),
                                    ),

                                    const Divider(
                                      height: 0,
                                      color: Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Divider(
                              height: 1,
                              color: (list.indexOf(item) + 1) != list.length
                                  ? Theme.of(context).dividerColor
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
              )
              .toList(),
        ),
      ),
    );
  }
}

String _checkRoutes(BuildContext ctx, String? routeName) {
  if (routeName == getTranslated('profile', ctx)) {
    return RouteHelper.profile;
  } else if (routeName == getTranslated('my_orders', ctx)) {
    return RouteHelper.orderListScreen;
  } else {
    return 'auth';
  }
}
