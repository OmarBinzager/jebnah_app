import 'package:flutter/material.dart';
import '../../../../common/providers/cart_provider.dart';
import '../../../../features/category/providers/category_provider.dart';
import '../../../../features/splash/providers/splash_provider.dart';
import '../../../../helper/route_helper.dart';
import '../../../../localization/language_constraints.dart';
import '../../../../utill/dimensions.dart';
import '../../../../utill/styles.dart';
import 'package:provider/provider.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final Widget? subTitle;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final bool isCenter;
  final bool isElevation;
  final bool fromCategory;
  final Widget? actionView;

  const CustomAppBarWidget({
    super.key,
    required this.title,
    this.isBackButtonExist = true,
    this.onBackPressed,
    this.isCenter = true,
    this.isElevation = false,
    this.fromCategory = false,
    this.actionView,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    return AppBar(
      title: Column(
        crossAxisAlignment: isCenter
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title!,
            style: poppinsMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          subTitle ?? const SizedBox(),
        ],
      ),
      centerTitle: isCenter ? true : false,
      leading: isBackButtonExist
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                  return;
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                  return;
                } else {
                  RouteHelper.getMainRoute(
                    action: RouteAction.pushNamedAndRemoveUntil,
                  );
                  Provider.of<SplashProvider>(
                    context,
                    listen: false,
                  ).setPageIndex(0);
                  return;
                }
              },
            )
          : const SizedBox(),
      backgroundColor: Theme.of(context).cardColor,
      elevation: isElevation ? 2 : 0,
      actions: [
        if (fromCategory)
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                  size: 25,
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

        fromCategory
            ? PopupMenuButton(
                elevation: 20,
                enabled: true,
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                onSelected: (String? value) {
                  int index = categoryProvider.allSortBy.indexOf(value);
                  categoryProvider.sortCategoryProduct(index);
                },

                itemBuilder: (context) {
                  return categoryProvider.allSortBy.map((choice) {
                    return PopupMenuItem(
                      value: choice,
                      child: Text(getTranslated(choice, context)),
                    );
                  }).toList();
                },
              )
            : const SizedBox(),

        actionView != null ? actionView! : const SizedBox(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 50);
}
