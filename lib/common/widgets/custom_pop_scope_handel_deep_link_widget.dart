import 'package:flutter/material.dart';
import '../../../../features/splash/providers/splash_provider.dart';
import '../../../../helper/responsive_helper.dart';
import '../../../../helper/route_helper.dart';
import 'package:provider/provider.dart';

class CustomPopScopeHandelDeepLinkWidget extends StatefulWidget {
  final Widget child;
  final Function()? onPopInvoked;
  const CustomPopScopeHandelDeepLinkWidget({
    super.key,
    required this.child,
    this.onPopInvoked,
  });

  @override
  State<CustomPopScopeHandelDeepLinkWidget> createState() =>
      _CustomPopScopeHandelDeepLinkWidgetState();
}

class _CustomPopScopeHandelDeepLinkWidgetState
    extends State<CustomPopScopeHandelDeepLinkWidget> {
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

        if (didPop) return;

        if (Navigator.canPop(context) && !ResponsiveHelper.isDesktop(context)) {
          Navigator.pop(context);
          return;
        } else if (!didPop && !Navigator.canPop(context)) {
          RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
          splashProvider.setPageIndex(0);
          return;
        }
      },
      child: widget.child,
    );
  }
}
