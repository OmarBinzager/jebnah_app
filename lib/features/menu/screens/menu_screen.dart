import 'package:flutter/material.dart';
import '../../../common/providers/localization_provider.dart';
import '../../../common/widgets/custom_asset_image_widget.dart';
import '../../../features/menu/domain/models/custom_drawer_controller_model.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../features/address/providers/location_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../common/providers/theme_provider.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../features/menu/screens/main_screen.dart';
import '../../../features/menu/widgets/menu_list_web_widget.dart';
import '../../../features/menu/widgets/custom_drawer_widget.dart';
import '../../../features/menu/widgets/sign_out_dialog_widget.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  final bool isReload;
  final bool fromIntro;
  const MenuScreen({super.key, this.isReload = true, this.fromIntro = false});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final CustomDrawerController _drawerController = CustomDrawerController();

  @override
  void initState() {
    super.initState();
    final bool isLoggedIn = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();
    if (isLoggedIn && widget.isReload) {
      Provider.of<ProfileProvider>(context, listen: false).getUserInfo(true);
      Provider.of<LocationProvider>(context, listen: false).initAddressList();
    } else {
      Provider.of<CartProvider>(context, listen: false).getCartData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocalizationProvider localizationProvider =
        Provider.of<LocalizationProvider>(context, listen: false);

    return CustomDrawerWidget(
      controller: _drawerController,
      menuScreen: MenuWidget(drawerController: _drawerController),
      mainScreen: MainScreen(
        drawerController: _drawerController,
        isReload: widget.isReload,
        fromIntro: widget.fromIntro,
      ),
      showShadow: false,
      angle: 0.0,
      borderRadius: 30,
      slideWidth:
          MediaQuery.of(context).size.width *
          (localizationProvider.isLtr ? 0.6 : 0.1),
    );
  }
}

class MenuWidget extends StatelessWidget {
  final CustomDrawerController? drawerController;

  const MenuWidget({super.key, this.drawerController});

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );
    final bool isLoggedIn = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!ResponsiveHelper.isDesktop(context) &&
            drawerController?.isOpen()) {
          drawerController?.toggle();
        }
      },
      child: Scaffold(
        backgroundColor:
            Provider.of<ThemeProvider>(context).darkTheme ||
                ResponsiveHelper.isDesktop(context)
            ? Theme.of(context).hintColor.withValues(alpha: 0.1)
            : Theme.of(context).primaryColor,

        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : null,
        body: SafeArea(
          child: ResponsiveHelper.isDesktop(context)
              ? Consumer<SplashProvider>(
                  builder: (context, splashProvider, _) {
                    return MenuListWebWidget(isLoggedIn: isLoggedIn);
                  },
                )
              : SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.webScreenWidth,
                      child: Consumer<SplashProvider>(
                        builder: (context, splash, child) {
                          return Column(
                            children: [
                              !ResponsiveHelper.isDesktop(context)
                                  ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color:
                                              Provider.of<ThemeProvider>(
                                                context,
                                              ).darkTheme
                                              ? Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color
                                                    ?.withValues(alpha: 0.6)
                                              : ResponsiveHelper.isDesktop(
                                                  context,
                                                )
                                              ? Theme.of(context).canvasColor
                                              : Theme.of(context).canvasColor,
                                        ),
                                        onPressed: () =>
                                            drawerController!.toggle(),
                                      ),
                                    )
                                  : const SizedBox(),

                              Consumer<ProfileProvider>(
                                builder: (context, profileProvider, child) => Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        onTap: () {
                                          RouteHelper.getProfileScreen();
                                        },
                                        leading: ClipOval(
                                          child: isLoggedIn
                                              ? splashProvider.baseUrls != null
                                                    ? CustomImageWidget(
                                                        placeholder:
                                                            Images.profile,
                                                        image:
                                                            '${splashProvider.baseUrls?.customerImageUrl}/${profileProvider.userInfoModel?.image}',
                                                        height: 50,
                                                        width: 50,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const SizedBox()
                                              : Image.asset(
                                                  Images.profile,
                                                  height: 50,
                                                  width: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            isLoggedIn
                                                ? profileProvider
                                                              .userInfoModel !=
                                                          null
                                                      ? Text(
                                                          '${profileProvider.userInfoModel!.fName ?? ''} ${profileProvider.userInfoModel!.lName ?? ''}',
                                                          style: poppinsRegular.copyWith(
                                                            color:
                                                                Provider.of<
                                                                      ThemeProvider
                                                                    >(context)
                                                                    .darkTheme
                                                                ? Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color
                                                                      ?.withValues(
                                                                        alpha:
                                                                            0.6,
                                                                      )
                                                                : ResponsiveHelper.isDesktop(
                                                                    context,
                                                                  )
                                                                ? ColorResources.getDarkColor(
                                                                    context,
                                                                  )
                                                                : Theme.of(
                                                                    context,
                                                                  ).canvasColor,
                                                          ),
                                                        )
                                                      : Container(
                                                          height: 10,
                                                          width: 150,
                                                          color:
                                                              ResponsiveHelper.isDesktop(
                                                                context,
                                                              )
                                                              ? ColorResources.getDarkColor(
                                                                  context,
                                                                )
                                                              : Theme.of(
                                                                  context,
                                                                ).canvasColor,
                                                        )
                                                : Text(
                                                    getTranslated(
                                                      'guest',
                                                      context,
                                                    ),
                                                    style: poppinsRegular.copyWith(
                                                      color:
                                                          Provider.of<
                                                                ThemeProvider
                                                              >(context)
                                                              .darkTheme
                                                          ? Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.color
                                                                ?.withValues(
                                                                  alpha: 0.6,
                                                                )
                                                          : ResponsiveHelper.isDesktop(
                                                              context,
                                                            )
                                                          ? ColorResources.getDarkColor(
                                                              context,
                                                            )
                                                          : Theme.of(
                                                              context,
                                                            ).canvasColor,
                                                    ),
                                                  ),
                                            if (isLoggedIn)
                                              const SizedBox(
                                                height:
                                                    Dimensions.paddingSizeSmall,
                                              ),

                                            if (isLoggedIn &&
                                                profileProvider.userInfoModel !=
                                                    null)
                                              Text(
                                                profileProvider
                                                        .userInfoModel!
                                                        .phone ??
                                                    '',
                                                style: poppinsRegular.copyWith(
                                                  color:
                                                      Provider.of<
                                                            ThemeProvider
                                                          >(context)
                                                          .darkTheme
                                                      ? Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color
                                                            ?.withValues(
                                                              alpha: 0.6,
                                                            )
                                                      : ResponsiveHelper.isDesktop(
                                                          context,
                                                        )
                                                      ? ColorResources.getDarkColor(
                                                          context,
                                                        )
                                                      : Theme.of(
                                                          context,
                                                        ).canvasColor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.notifications,
                                        color:
                                            Provider.of<ThemeProvider>(
                                              context,
                                            ).darkTheme
                                            ? Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color
                                                  ?.withValues(alpha: 0.6)
                                            : ResponsiveHelper.isDesktop(
                                                context,
                                              )
                                            ? ColorResources.getDarkColor(
                                                context,
                                              )
                                            : Theme.of(context).canvasColor,
                                      ),
                                      onPressed: () {
                                        RouteHelper.getNotificationScreen();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 50),

                              if (!ResponsiveHelper.isDesktop(context))
                                Column(
                                  children: splashProvider.screenList
                                      .map(
                                        (model) => model.isActive
                                            ? ListTile(
                                                onTap: () {
                                                  if (!ResponsiveHelper.isDesktop(
                                                    context,
                                                  )) {
                                                    splash.setPageIndex(
                                                      splashProvider.screenList
                                                          .indexOf(model),
                                                    );
                                                  }
                                                  drawerController!.toggle();
                                                },
                                                selected:
                                                    splash.pageIndex ==
                                                    splashProvider.screenList
                                                        .indexOf(model),
                                                selectedTileColor: Colors.black
                                                    .withAlpha(30),
                                                leading: CustomAssetImageWidget(
                                                  model.icon,
                                                  color:
                                                      ResponsiveHelper.isDesktop(
                                                        context,
                                                      )
                                                      ? ColorResources.getDarkColor(
                                                          context,
                                                        )
                                                      : Colors.white,
                                                  width: 25,
                                                  height: 25,
                                                ),
                                                title: Text(
                                                  getTranslated(
                                                    model.title,
                                                    context,
                                                  ),
                                                  style: poppinsRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                    color:
                                                        Provider.of<
                                                              ThemeProvider
                                                            >(context)
                                                            .darkTheme
                                                        ? Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.color
                                                              ?.withValues(
                                                                alpha: 0.6,
                                                              )
                                                        : ResponsiveHelper.isDesktop(
                                                            context,
                                                          )
                                                        ? ColorResources.getDarkColor(
                                                            context,
                                                          )
                                                        : Theme.of(
                                                            context,
                                                          ).canvasColor,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      )
                                      .toList(),
                                ),

                              ListTile(
                                onTap: () {
                                  if (isLoggedIn) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          const SignOutDialogWidget(),
                                    );
                                  } else {
                                    splashProvider.setPageIndex(0);
                                    RouteHelper.getLoginRoute(
                                      action:
                                          RouteAction.pushNamedAndRemoveUntil,
                                    );
                                  }
                                },
                                leading: CustomAssetImageWidget(
                                  isLoggedIn ? Images.logOut : Images.logIn,
                                  width: 25,
                                  height: 25,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  getTranslated(
                                    isLoggedIn ? 'log_out' : 'login',
                                    context,
                                  ),
                                  style: poppinsRegular.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color:
                                        Provider.of<ThemeProvider>(
                                          context,
                                        ).darkTheme
                                        ? Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color
                                              ?.withValues(alpha: 0.6)
                                        : ResponsiveHelper.isDesktop(context)
                                        ? ColorResources.getDarkColor(context)
                                        : Theme.of(context).canvasColor,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class MenuButton {
  final String routeName;
  final String icon;
  final String title;
  final IconData? iconData;
  MenuButton({
    required this.routeName,
    required this.icon,
    required this.title,
    this.iconData,
  });
}
