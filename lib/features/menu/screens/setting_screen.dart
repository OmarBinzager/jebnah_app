import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/models/config_model.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../common/providers/theme_provider.dart';
import '../../../common/widgets/custom_image_widget.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../common/widgets/main_app_bar_widget.dart';
import '../../../features/address/providers/location_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/menu/widgets/currency_dialog_widget.dart';
import '../../../features/menu/widgets/sign_out_dialog_widget.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../../../helper/dialog_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import '../widgets/acount_delete_dialog_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateUserData();
  }

  Future<void> _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isLoggedIn();

    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
      });
    }

    if (isLoggedIn) {
      await Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).getUserInfo(true);
      await Provider.of<LocationProvider>(
        context,
        listen: false,
      ).initAddressList();
    } else {
      Provider.of<CartProvider>(context, listen: false).getCartData();
    }
  }

  void _updateUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isLoggedIn();

    if (_isLoggedIn != isLoggedIn) {
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
        });
      }

      if (isLoggedIn) {
        Provider.of<ProfileProvider>(context, listen: false).getUserInfo(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SplashProvider>(context, listen: false).setFromSetting(true);
    final authProvider = Provider.of<AuthProvider>(context);
    final splashProvider = Provider.of<SplashProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final bool isLoggedIn = authProvider.isLoggedIn();
    final userInfo = profileProvider.userInfoModel;
    final hasUserData = isLoggedIn && userInfo != null;
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = themeProvider.darkTheme;

    final cardBackgroundColor = isDark ? const Color(0xFF242526) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final List<SocialMediaLink> activeSocialMediaList = splashProvider
            .configModel?.socialMediaLink
            ?.where((item) =>
                (item.status == 1 || item.status == null) &&
                item.link != null &&
                item.link!.trim().isNotEmpty)
            .toList() ??
        [];

    // قائمة إعدادات وتفضيلات الحساب الرئيسية
    final List<Map<String, String>> settingsItems = [
      {'title': getTranslated('dark_theme', context), 'route': 'dark_theme'},
      {'title': getTranslated('choose_language', context), 'route': 'language'},
      {
        'title': getTranslated('notifications', context),
        'route': 'notifications',
      },
      {'title': getTranslated('address', context), 'route': 'address'},
      {'title': getTranslated('favorites', context), 'route': 'favorites'},
      {'title': getTranslated('my_order', context), 'route': 'my_order'},
      if (splashProvider.configModel?.walletStatus == true)
        {'title': getTranslated('wallet', context), 'route': 'wallet'},
      if (splashProvider.configModel?.loyaltyPointStatus == true)
        {
          'title': getTranslated('loyalty_point', context),
          'route': 'loyalty_point',
        },
      if (splashProvider.configModel?.referEarnStatus == true)
        {
          'title': getTranslated('referAndEarn', context),
          'route': 'referAndEarn',
        },

      {'title': getTranslated('coupon', context), 'route': 'coupon'},
      {'title': getTranslated('live_chat', context), 'route': 'live_chat'},
      if (authProvider.isLoggedIn())
        {
          'title': getTranslated('delete_account', context),
          'route': 'delete_account',
        },
    ];

    // قائمة الصفحات والسياسات والمعلومات العامة
    final List<Map<String, String>> infoItems = [
      {'title': getTranslated('faq', context), 'route': 'faq'},
      {
        'title': getTranslated('terms_and_condition', context),
        'route': 'terms_and_condition',
      },
      {
        'title': getTranslated('privacy_policy', context),
        'route': 'privacy_policy',
      },
      if (splashProvider.configModel?.returnPolicyStatus ?? true)
        {
          'title': getTranslated('return_policy', context),
          'route': 'return_policy',
        },
      if (splashProvider.configModel?.refundPolicyStatus ?? true)
        {
          'title': getTranslated('refund_policy', context),
          'route': 'refund_policy',
        },
      if (splashProvider.configModel?.cancellationPolicyStatus ?? true)
        {
          'title': getTranslated('cancellation_policy', context),
          'route': 'cancellation_policy',
        },
      {'title': getTranslated('about_us', context), 'route': 'about_us'},
    ];

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        backgroundColor: isDark
            ? ColorResources.getDarkColor(context)
            : const Color(0xFFF7F9FA),
        appBar: ResponsiveHelper.isDesktop(context)
            ? const MainAppBarWidget()
            : null,
        body: Center(
          child: SizedBox(
            width: 1170,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              children: [
                // 1. بطاقة بيانات المستخدم
                _buildUserProfileCard(
                  context,
                  isLoggedIn,
                  hasUserData,
                  userInfo,
                  splashProvider,
                  primaryColor,
                ),

                const SizedBox(height: 12),

                // 2. بطاقة المحفظة (إن كانت مفعلة من السيرفر)
                if (splashProvider.configModel?.walletStatus == true) ...[
                  _buildWalletCard(context, primaryColor, userInfo),
                  const SizedBox(height: 12),
                ],

                // 3. الأزرار السريعة الثلاثية
                _buildQuickActionsGrid(context, primaryColor),

                const SizedBox(height: 16),

                // 4. مجموعة الإعدادات الرئيسية
                _buildGroupCard(
                  context,
                  title: getTranslated('settings', context),
                  items: settingsItems,
                  cardBackgroundColor: cardBackgroundColor,
                  textColor: textColor,
                  splashProvider: splashProvider,
                  authProvider: authProvider,
                ),

                const SizedBox(height: 16),

                // 5. مجموعة المعلومات والسياسات
                _buildGroupCard(
                  context,
                  title: getTranslated('information', context),
                  items: infoItems,
                  cardBackgroundColor: cardBackgroundColor,
                  textColor: textColor,
                  splashProvider: splashProvider,
                  authProvider: authProvider,
                ),

                if (activeSocialMediaList.isNotEmpty) ...[
                  const SizedBox(height: 20),

                  // 6. عنوان تابعنا
                  Center(
                    child: Text(
                      getTranslated('follow_us', context),
                      style: poppinsBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 7. أزرار شبكات التواصل الاجتماعي
                  _buildSocialIconsRow(activeSocialMediaList, textColor),
                ],

                const SizedBox(height: 20),

                // 8. زر الفروع
                _buildBranchButton(context, primaryColor, cardBackgroundColor),

                const SizedBox(height: 16),

                // 9. زر تسجيل الخروج / تسجيل الدخول
                _buildLogoutButton(context, isLoggedIn),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== بطاقة بيانات المستخدم =====================
  Widget _buildUserProfileCard(
    BuildContext context,
    bool isLoggedIn,
    bool hasUserData,
    dynamic userInfo,
    SplashProvider splashProvider,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child:
                  isLoggedIn &&
                      hasUserData &&
                      userInfo.image != null &&
                      userInfo.image!.isNotEmpty
                  ? CustomImageWidget(
                      placeholder: Images.profile,
                      image:
                          '${splashProvider.baseUrls?.customerImageUrl}/${userInfo.image}',
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.person, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn && hasUserData
                      ? '${userInfo.fName ?? ''} ${userInfo.lName ?? ''}'.trim()
                      : (isLoggedIn && !hasUserData
                            ? (getTranslated('loading', context))
                            : getTranslated('guest', context)),
                  style: poppinsBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLoggedIn && hasUserData && userInfo.email != null
                      ? userInfo.email!
                      : (isLoggedIn ? '' : 'guest@app.com'),
                  style: poppinsRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          if (isLoggedIn)
            InkWell(
              onTap: () => RouteHelper.getProfileEditRoute(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  // ===================== بطاقة المحفظة =====================
  Widget _buildWalletCard(
    BuildContext context,
    Color primaryColor,
    dynamic userInfo,
  ) {
    final double walletBalance = userInfo?.walletBalance ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated('you_have_in_wallet', context),
                    style: poppinsRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ' ${walletBalance.toStringAsFixed(2)}',
                    style: poppinsBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: () => RouteHelper.getWalletRoute(),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== الأزرار السريعة الثلاثية =====================
  Widget _buildQuickActionsGrid(BuildContext context, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.inventory_2_outlined,
            title: getTranslated('my_order', context),
            primaryColor: primaryColor,
            onTap: () => RouteHelper.getOrderListScreen(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.location_on_outlined,
            title: getTranslated('address', context),
            primaryColor: primaryColor,
            onTap: () => RouteHelper.getAddressListScreen(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.gamepad,
            title: getTranslated('game_point', context),
            primaryColor: primaryColor,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: poppinsMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== كارت موحد للمجموعات =====================
  Widget _buildGroupCard(
    BuildContext context, {
    required String title,
    required List<Map<String, String>> items,
    required Color cardBackgroundColor,
    required Color textColor,
    required SplashProvider splashProvider,
    required AuthProvider authProvider,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 16,
              left: 16,
              top: 12,
              bottom: 4,
            ),
            child: Text(
              title,
              style: poppinsBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: textColor,
              ),
            ),
          ),
          Column(
            children: items.asMap().entries.map((entry) {
              int idx = entry.key;
              var item = entry.value;
              bool isDelete = item['route'] == 'delete_account';
              bool isDarkToggle = item['route'] == 'dark_theme';

              return Column(
                children: [
                  ListTile(
                    onTap: () => _handleNavigation(
                      context,
                      item['route']!,
                      splashProvider,
                      authProvider,
                    ),
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    title: Text(
                      item['title']!,
                      style: poppinsMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: isDelete ? Colors.red.shade700 : textColor,
                      ),
                    ),
                    trailing: isDarkToggle
                        ? Switch(
                            value: themeProvider.darkTheme,
                            onChanged: (_) => themeProvider.toggleTheme(),
                            activeColor: Theme.of(context).primaryColor,
                          )
                        : Icon(
                            Icons.arrow_forward_ios,
                            color: isDelete
                                ? Colors.red.shade700
                                : textColor.withOpacity(0.5),
                            size: 16,
                          ),
                  ),
                  if (idx != items.length - 1)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ===================== صف أيقونات التواصل الاجتماعي =====================
  Widget _buildSocialIconsRow(
    List<SocialMediaLink> socialMediaList,
    Color textColor,
  ) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: socialMediaList
            .map((social) => _buildSocialIcon(social, textColor))
            .toList(),
      ),
    );
  }

  Widget _buildSocialIcon(SocialMediaLink socialMedia, Color textColor) {
    final String name = (socialMedia.name ?? '').trim().toLowerCase();
    String? assetImage;
    IconData? fallbackIcon;

    if (name.contains('facebook')) {
      assetImage = Images.facebook;
    } else if (name.contains('instagram')) {
      assetImage = Images.inStaGramIcon;
    } else if (name.contains('twitter') || name == 'x') {
      assetImage = Images.twitter;
    } else if (name.contains('youtube')) {
      assetImage = Images.youtube;
    } else if (name.contains('linkedin')) {
      assetImage = Images.linkedInIcon;
    } else if (name.contains('pinterest')) {
      assetImage = Images.pinterest;
    } else if (name.contains('whatsapp')) {
      assetImage = Images.whatsapp;
    } else if (name.contains('telegram')) {
      assetImage = Images.telegram;
    } else if (name.contains('messenger')) {
      assetImage = Images.messenger;
    } else if (name.contains('snapchat')) {
      fallbackIcon = Icons.camera_alt_outlined;
    } else if (name.contains('tiktok')) {
      fallbackIcon = Icons.music_note_outlined;
    } else {
      fallbackIcon = Icons.public;
    }

    return InkWell(
      onTap: () {
        if (socialMedia.link != null && socialMedia.link!.trim().isNotEmpty) {
          _launchSocialURL(socialMedia.link!);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: textColor.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: assetImage != null
            ? Image.asset(assetImage, fit: BoxFit.contain)
            : Icon(fallbackIcon, size: 18, color: textColor),
      ),
    );
  }

  Future<void> _launchSocialURL(String url) async {
    String formattedUrl = url.trim();
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    final Uri uri = Uri.parse(formattedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBarHelper('Could not launch $url');
    }
  }

  // ===================== زر زيارة الفروع =====================
  Widget _buildBranchButton(
    BuildContext context,
    Color primaryColor,
    Color cardBackgroundColor,
  ) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor, width: 1.2),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              getTranslated('visit_our_branches', context),
              style: poppinsBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== زر تسجيل الخروج =====================
  Widget _buildLogoutButton(BuildContext context, bool isLoggedIn) {
    return InkWell(
      onTap: () {
        if (isLoggedIn) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const SignOutDialogWidget(),
          );
        } else {
          RouteHelper.getLoginRoute(
            action: RouteAction.pushNamedAndRemoveUntil,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLoggedIn ? Icons.logout : Icons.login,
              color: const Color(0xFFD32F2F),
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              isLoggedIn
                  ? (getTranslated('logout', context))
                  : (getTranslated('login', context)),
              style: poppinsBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== توجيه المسارات وحالات النقر =====================
  void _handleNavigation(
    BuildContext context,
    String route,
    SplashProvider splashProvider,
    AuthProvider authProvider,
  ) {
    switch (route) {
      case 'dark_theme':
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        break;

      case 'language':
        showDialogHelper(context, const CurrencyDialogWidget());
        break;

      case 'notifications':
        RouteHelper.getNotificationScreen();
        break;

      case 'address':
        RouteHelper.getAddressListScreen();
        break;

      case 'favorites':
        splashProvider.setPageIndex(3);
        RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
        break;

      case 'my_order':
        RouteHelper.getOrderListScreen();
        break;

      case 'wallet':
        RouteHelper.getWalletRoute();
        break;

      case 'loyalty_point':
        RouteHelper.getLoyaltyScreen();
        break;
      case 'referAndEarn':
        RouteHelper.getReferAndEarnRoute();
        break;
      case 'coupon':
        RouteHelper.getCouponRoute();
        break;

      case 'live_chat':
        RouteHelper.getChatRoute(
          orderId: "",
          profileImage: "",
          userName: "",
          senderType: "admin",
        );
        break;

      case 'return_policy':
        RouteHelper.getReturnPolicyRoute();
        break;

      case 'refund_policy':
        RouteHelper.getRefundPolicyRoute();
        break;

      case 'cancellation_policy':
        RouteHelper.getCancellationPolicyRoute();
        break;

      case 'faq':
        RouteHelper.getFaqRoute();
        break;

      case 'terms_and_condition':
      case 'terms_conditions':
        RouteHelper.getTermsRoute();
        break;

      case 'privacy_policy':
        RouteHelper.getPolicyRoute();
        break;

      case 'about_us':
        RouteHelper.getAboutUsRoute();
        break;

      case 'delete_account':
        showDialogHelper(
          context,
          AccountDeleteDialogWidget(
            icon: Icons.question_mark_sharp,
            title: getTranslated('are_you_sure_to_delete_account', context),
            description: getTranslated(
              'it_will_remove_your_all_information',
              context,
            ),
            onTapFalseText: getTranslated('no', context),
            onTapTrueText: getTranslated('yes', context),
            isFailed: true,
            onTapFalse: () => Navigator.of(context).pop(),
            onTapTrue: () => authProvider.deleteUser(context),
          ),
          dismissible: false,
          isFlip: true,
        );
        break;

      default:
        break;
    }
  }
}

// ===================== فئة الألوان المساعدة =====================
class ColorResources {
  static Color getDarkColor(BuildContext context) {
    return const Color(0xFF18191A);
  }
}
