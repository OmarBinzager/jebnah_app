import 'package:go_router/go_router.dart';
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

    final bool canPop = ResponsiveHelper.isWeb() ? true : (context.canPop() || Navigator.canPop(context));

    return PopScope<Object?>(
      canPop: canPop,
      onPopInvokedWithResult: (bool didPop, _) {
        if (widget.onPopInvoked != null) {
          widget.onPopInvoked!();
        }

        if (didPop) return;

        if (context.canPop()) {
          context.pop();
          return;
        } else if (Navigator.canPop(context) && !ResponsiveHelper.isDesktop(context)) {
          Navigator.pop(context);
          return;
        } else if (!didPop) {
          RouteHelper.getMainRoute(
            action: RouteAction.pushNamedAndRemoveUntil,
          );
          return;
        }
      },
      child: widget.child,
    );
  }
}
