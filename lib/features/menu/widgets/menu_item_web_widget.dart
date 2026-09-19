import 'package:flutter/material.dart';
import '../../../common/widgets/custom_asset_image_widget.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/menu/domain/models/menu_model.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class MenuItemWebWidget extends StatelessWidget {
  final MenuModel menu;
  const MenuItemWebWidget({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    bool isLogin = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();
    return InkWell(
      borderRadius: BorderRadius.circular(32.0),
      onTap: () {
        menu.route();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            menu.iconWidget != null
                ? menu.iconWidget!
                : CustomAssetImageWidget(
                    menu.icon,
                    width: 50,
                    height: 50,
                    color:
                        (menu.title ==
                                getTranslated(
                                  isLogin ? 'log_out' : 'login',
                                  context,
                                )) &&
                            isLogin
                        ? Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.7)
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(menu.title!, style: poppinsRegular),
          ],
        ),
      ),
    );
  }
}
