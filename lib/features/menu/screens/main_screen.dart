import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../common/widgets/custom_button_widget.dart';
import '../../../common/widgets/custom_pop_scope_widget.dart';
import '../../../features/menu/domain/models/custom_drawer_controller_model.dart';
import '../../../features/refer_and_earn/screens/refer_hint_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../features/address/providers/location_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../common/providers/theme_provider.dart';

import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../../features/home/screens/home_screens.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  final bool isReload;
  final bool fromIntro;
  final CustomDrawerController drawerController;
  const MainScreen({
    super.key,
    required this.drawerController,
    this.isReload = true,
    this.fromIntro = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool canExit = kIsWeb;

  @override
  void initState() {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );
    splashProvider.initializeScreenList();
    if (widget.isReload) {
      HomeScreen.loadData(true, context);
    }
    if (widget.fromIntro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBottomSheet(context);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Provider.of<ThemeProvider>(context).darkTheme;

    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Consumer<SplashProvider>(
      builder: (context, splash, child) {
        return CustomPopScopeWidget(
          child: Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              return Consumer<LocationProvider>(
                builder: (context, locationProvider, child) => InkWell(
                  onTap: () {
                    if (!ResponsiveHelper.isDesktop(context) &&
                        widget.drawerController.isOpen()) {
                      widget.drawerController.toggle();
                    }
                  },
                  child: Scaffold(
                    // Floating Action Button لسلة المشتريات مع تعديل المسافة
                    floatingActionButton: !isDesktop
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildFloatingCartButton(
                              splash,
                              isDarkTheme,
                            ),
                          )
                        : null,
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerDocked,
                    floatingActionButtonAnimator:
                        FloatingActionButtonAnimator.scaling,

                    appBar: ResponsiveHelper.isDesktop(context)
                        ? null
                        : AppBar(
                            // toolbarHeight: 65,
                            backgroundColor: Theme.of(context).cardColor,
                            title: splash.pageIndex == 0
                                ? Row(
                                    children: [
                                      Image.asset(
                                        isDarkTheme
                                            ? Images.darkAppLogo
                                            : Images.webBarLogoPlaceHolder,
                                        height: 120,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeExtraLarge,
                                      ),
                                    ],
                                  )
                                : Text(
                                    getTranslated(
                                      splash.screenList[splash.pageIndex].title,
                                      context,
                                    ),
                                    style: poppinsMedium.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                            elevation: 1,
                            actions: [
                              if (splash.screenList[splash.pageIndex].title ==
                                  'home') ...[
                                IconButton(
                                  icon: Image.asset(
                                    Images.search,
                                    color: Theme.of(context).primaryColor,
                                    width: 20,
                                  ),
                                  onPressed: () {
                                    RouteHelper.getSearchProduct();
                                  },
                                ),
                              ],
                              if (splash.screenList[splash.pageIndex].title ==
                                  'loyalty_point') ...[
                                IconButton(
                                  onPressed: () {
                                    ResponsiveHelper().showDialogOrBottomSheet(
                                      context,
                                      ReferHintWidget(
                                        hintList: profileProvider.hintList,
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.info_outline),
                                ),
                              ],
                              // إضافة أيقونة الجرس للتنبيهات
                              IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                                onPressed: () {
                                  RouteHelper.getNotificationScreen();
                                },
                              ),
                            ],
                          ),

                    // قائمة سفلية متباعدة مع مسافة من زر السلة
                    bottomNavigationBar: !isDesktop
                        ? _buildBottomNavigationBar(splash)
                        : null,

                    body: splash.screenList[splash.pageIndex].screen,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // دالة لبناء Floating Action Button لسلة المشتريات
  Widget _buildFloatingCartButton(SplashProvider splash, bool isDarkTheme) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartQuantity = cartProvider.getTotalCartQuantity();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton(
            onPressed: () {
              splash.setPageIndex(2); // الانتقال إلى صفحة السلة
            },
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 8,
            shape: const CircleBorder(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_bag, color: Colors.white, size: 28),
                if (cartQuantity > 0)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 22,
                        minHeight: 22,
                      ),
                      child: Text(
                        cartQuantity > 99 ? '99+' : '$cartQuantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // دالة لبناء القائمة السفلية المتباعدة والجميلة
  Widget _buildBottomNavigationBar(SplashProvider splash) {
    // تعريف عناصر القائمة (4 عناصر فقط)
    final List<NavigationItem> navItems = [
      NavigationItem(
        label: getTranslated('home', context),
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        index: 0, // الرئيسية
      ),
      NavigationItem(
        label: getTranslated('categories', context),
        icon: Icons.category_outlined,
        activeIcon: Icons.category,
        index: 1, // الفئات
      ),
      NavigationItem(
        label: getTranslated('favorites', context),
        icon: Icons.favorite_border,
        activeIcon: Icons.favorite,
        index: 3, // المفضلة
      ),
      NavigationItem(
        label: getTranslated('my_account', context),
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        index: 13, // حسابي
      ),
    ];

    // حساب المؤشر الحالي للقائمة السفلية
    int getBottomNavIndex() {
      final currentIndex = splash.pageIndex;
      if (currentIndex == 0) return 0; // الرئيسية
      if (currentIndex == 1) return 1; // الفئات
      if (currentIndex == 3) return 2; // المفضلة
      if (currentIndex == 13) return 3; // حسابي
      return 0;
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: getBottomNavIndex(),
        onTap: (bottomNavIndex) {
          int newPageIndex;
          switch (bottomNavIndex) {
            case 0:
              newPageIndex = 0;
              break;
            case 1:
              newPageIndex = 1;
              break;
            case 2:
              newPageIndex = 3;
              break;
            case 3:
              newPageIndex = 12;
              break;
            default:
              newPageIndex = 0;
          }
          splash.setPageIndex(newPageIndex);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).hintColor.withValues(alpha: 0.6),
        selectedLabelStyle: poppinsMedium.copyWith(
          fontSize: Dimensions.fontSizeDefault,
        ),
        unselectedLabelStyle: poppinsRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
        ),
        elevation: 0,
        // إضافة مسافة داخلية للقائمة
        enableFeedback: true,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Icon(item.icon, size: 28),
            ),
            activeIcon: Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Icon(item.activeIcon, size: 28),
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

// نموذج لعناصر القائمة
class NavigationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int index;

  NavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.index,
  });
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 25),
                Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                    ),
                    padding: EdgeInsets.all(7),
                    child: Image.asset(
                      Images.crossIcon,
                      height: Dimensions.paddingSizeSmall,
                      width: Dimensions.paddingSizeSmall,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Image.asset(Images.lockIcon, height: 60, width: 60),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              getTranslated('you_are_almost_there', context),
              style: poppinsBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              getTranslated('log_in_or_sign_up_to_continue_and_enjoy', context),
              style: poppinsRegular.copyWith(
                fontSize: Dimensions.fontSizeLarge,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: CustomButtonWidget(
                onPressed: () => RouteHelper.getLoginRoute(
                  action: RouteAction.pushNamedAndRemoveUntil,
                ),
                buttonText: getTranslated('login_or_signup', context),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            if ((Provider.of<SplashProvider>(
                  context,
                  listen: false,
                ).configModel?.isGuestCheckout ??
                false)) ...[
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(1, 40)),
                  onPressed: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${getTranslated('continue_as_a', context)} ',
                          style: poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.6),
                          ),
                        ),
                        TextSpan(
                          text: getTranslated('guest', context),
                          style: poppinsRegular.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],
          ],
        ),
      );
    },
  );
}
