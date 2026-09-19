import 'package:flutter/material.dart';
import '../../../../helper/route_helper.dart';
import '../../../../common/providers/cart_provider.dart';
import '../../../../utill/images.dart';
import '../../../../utill/styles.dart';
import 'package:provider/provider.dart';

class AppBarBaseWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  const AppBarBaseWidget({super.key, this.title = ''});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Navigator.canPop(context)
          ? IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            )
          : null,

      title: Text(
        title!,
        style: poppinsMedium.copyWith(
          color: Theme.of(context).textTheme.bodyLarge!.color,
        ),
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).cardColor,
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                Images.cartIcon,
                color: Theme.of(context).textTheme.bodyLarge!.color,
                width: 25,
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
                    '${Provider.of<CartProvider>(context).cartList.length}',
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
            RouteHelper.getCartScreen();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            size: 30,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
          onPressed: () {
            RouteHelper.getSearchProduct();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 50);
}
