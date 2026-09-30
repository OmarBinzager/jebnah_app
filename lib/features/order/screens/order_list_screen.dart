import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/app_localization.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/app_bar_base_widget.dart';
import '../../../common/widgets/not_login_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../features/order/widgets/order_widget.dart';
import 'package:provider/provider.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    final bool isLoggedIn = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();
    Provider.of<OrderProvider>(
      context,
      listen: false,
    ).changeActiveOrderStatus(true, isUpdate: false);

    _tabController = TabController(
      length: 2,
      initialIndex: 0,
      vsync: this,
      animationDuration: const Duration(milliseconds: 100),
    );

    _tabController?.addListener(() {
      if (!mounted) return;
      if (_tabController != null && !_tabController!.indexIsChanging) {
        Provider.of<OrderProvider>(
          context,
          listen: false,
        ).changeActiveOrderStatus(_tabController!.index == 0);
      }
    });

    if (isLoggedIn) {
      Provider.of<OrderProvider>(context, listen: false).getOrderList(context);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isMobilePhone()
            ? null
            : ((ResponsiveHelper.isDesktop(context) || kIsWeb)
                      ? const PreferredSize(
                          preferredSize: Size.fromHeight(130),
                          child: WebAppBarWidget(),
                        )
                      : const AppBarBaseWidget())
                  as PreferredSizeWidget?,

        body: isLoggedIn
            ? Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  return Column(
                    children: [
                      ResponsiveHelper.isDesktop(context)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraLarge,
                              ),
                              child: Text(
                                "my_orders".tr,
                                style: poppinsSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                            )
                          : const SizedBox(),

                      Center(
                        child: TabBar(
                          onTap: (int? index) =>
                              orderProvider.changeActiveOrderStatus(index == 0),
                          tabAlignment: TabAlignment.center,
                          controller: _tabController,
                          labelColor: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.color,
                          indicatorColor: Theme.of(context).primaryColor,
                          indicatorWeight: 3,
                          unselectedLabelStyle: poppinsRegular.copyWith(
                            color: Theme.of(context).disabledColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                          labelStyle: poppinsMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                          tabs: [
                            Tab(text: getTranslated('ongoing', context)),
                            Tab(text: getTranslated('history', context)),
                          ],
                        ),
                      ),

                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: const [
                            OrderWidget(isRunning: true),
                            OrderWidget(isRunning: false),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              )
            : const NotLoggedInWidget(),
      ),
    );
  }
}
