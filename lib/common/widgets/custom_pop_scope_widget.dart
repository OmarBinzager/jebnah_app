import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../common/widgets/custom_alert_dialog_widget.dart';
import '../../../../features/splash/providers/splash_provider.dart';
import '../../../../helper/responsive_helper.dart';
import '../../../../helper/route_helper.dart';
import '../../../../localization/language_constraints.dart';
import '../../../../utill/dimensions.dart';
import 'package:provider/provider.dart';

class CustomPopScopeWidget extends StatefulWidget {
  final Widget child;
  final Function()? onPopInvoked;
  const CustomPopScopeWidget({
    super.key,
    required this.child,
    this.onPopInvoked,
  });

  @override
  State<CustomPopScopeWidget> createState() => _CustomPopScopeWidgetState();
}

class _CustomPopScopeWidgetState extends State<CustomPopScopeWidget> {
  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return PopScope<Object?>(
      canPop: ResponsiveHelper.isWeb() ? true : false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (widget.onPopInvoked != null) {
          widget.onPopInvoked!();
        }

        if (splashProvider.pageIndex != 0) {
          RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
          splashProvider.setPageIndex(0);
          return;
        }

        if (!didPop && (splashProvider.pageIndex == 0)) {
          ResponsiveHelper().showDialogOrBottomSheet(
            context,
            CustomAlertDialogWidget(
              title: getTranslated('close_the_app', context),
              subTitle: getTranslated('do_you_want_to_close_and', context),
              rightButtonText: getTranslated('exit', context),
              iconWidget: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Icon(Icons.logout, color: Colors.white, size: 40),
                ),
              ),
              onPressRight: () {
                exit(0);
              },
            ),
          );
        }
      },
      child: widget.child,
    );
  }
}
