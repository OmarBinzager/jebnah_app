import 'package:flutter/material.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/route_helper.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class DetailsAppBarWidget extends StatefulWidget
    implements PreferredSizeWidget {
  final String? title;
  const DetailsAppBarWidget({super.key, this.title});

  @override
  DetailsAppBarWidgetState createState() => DetailsAppBarWidgetState();

  @override
  Size get preferredSize => const Size(double.maxFinite, 50);
}

class DetailsAppBarWidgetState extends State<DetailsAppBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  void shake() {
    controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation =
        Tween(
            begin: 0.0,
            end: 15.0,
          ).chain(CurveTween(curve: Curves.elasticIn)).animate(controller)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              controller.reverse();
            }
          });

    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).textTheme.bodyLarge!.color,
          size: 20,
        ),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            return;
          } else if (!Navigator.canPop(context)) {
            RouteHelper.getMainRoute(
              action: RouteAction.pushNamedAndRemoveUntil,
            );
            Provider.of<SplashProvider>(context, listen: false).setPageIndex(0);
            return;
          }
        },
      ),
      elevation: 1,
      shadowColor: Colors.grey.withValues(alpha: 0.3),
      backgroundColor: Theme.of(context).cardColor,
      title: Text(
        widget.title!,
        style: poppinsMedium.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          color: Theme.of(context).textTheme.bodyLarge!.color,
        ),
      ),
      centerTitle: true,
      actions: [
        AnimatedBuilder(
          animation: offsetAnimation,
          builder: (buildContext, child) {
            return Container(
              padding: EdgeInsets.only(
                left: offsetAnimation.value + 15.0,
                right: 15.0 - offsetAnimation.value,
              ),
              child: IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: Theme.of(
                        context,
                      ).disabledColor.withValues(alpha: 0.3),
                      size: 30,
                    ),
                    Positioned(
                      top: -7,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          '${Provider.of<CartProvider>(context).getTotalCartQuantity()}',
                          style: TextStyle(
                            color: Theme.of(context).cardColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Provider.of<SplashProvider>(
                    context,
                    listen: false,
                  ).setPageIndex(2);
                  RouteHelper.getMainRoute(action: RouteAction.pushReplacement);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
