import 'package:flutter/material.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/not_login_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../features/profile/widgets/profile_details_widget.dart';
import '../../../features/profile/widgets/profile_header_widget.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();

    if (_isLoggedIn) {
      Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).getUserInfo(true, isUpdate: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );
    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : AppBar(
                backgroundColor: Theme.of(context).cardColor,
                leading: IconButton(
                  icon: Image.asset(
                    Images.moreIcon,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    splashProvider.setPageIndex(0);
                    if (Navigator.canPop(context) &&
                        !ResponsiveHelper.isDesktop(context)) {
                      Navigator.pop(context);
                      return;
                    } else if (!Navigator.canPop(context)) {
                      RouteHelper.getMainRoute(
                        action: RouteAction.pushNamedAndRemoveUntil,
                      );
                      return;
                    }
                  },
                ),
                title: Text(
                  getTranslated('profile', context),
                  style: poppinsMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
        body: SafeArea(
          child: _isLoggedIn
              ? Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: ProfileHeaderWidget()),

                          SliverToBoxAdapter(child: ProfileDetailsWidget()),

                          FooterWebWidget(footerType: FooterType.sliver),
                        ],
                      ),
                    );
                  },
                )
              : const NotLoggedInWidget(),
        ),
      ),
    );
  }
}
