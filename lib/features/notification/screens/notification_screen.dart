import 'package:flutter/material.dart';
import '../../../common/enums/footer_type_enum.dart';
import '../../../features/notification/widgets/notification_item_widget.dart';
import '../../../features/splash/providers/splash_provider.dart';
import '../../../helper/date_converter_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/app_localization.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/notification/providers/notification_provider.dart';
import '../../../common/widgets/custom_app_bar_widget.dart';
import '../../../common/widgets/custom_loader_widget.dart';
import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/no_data_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).getNotificationList(isUpdate: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );

    return PopScope(
      canPop: ResponsiveHelper.isWeb() ? true : false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) return;

        if (Navigator.canPop(context) && !ResponsiveHelper.isDesktop(context)) {
          Navigator.pop(context);
          return;
        } else if (!didPop && !Navigator.canPop(context)) {
          RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
          splashProvider.setPageIndex(0);
          return;
        }
      },
      child: Scaffold(
        appBar:
            (ResponsiveHelper.isDesktop(context)
                    ? const PreferredSize(
                        preferredSize: Size.fromHeight(120),
                        child: WebAppBarWidget(),
                      )
                    : CustomAppBarWidget(
                        title: getTranslated('notification', context),
                        onBackPressed: () {
                          if (!Navigator.canPop(context)) {
                            RouteHelper.getMainRoute(
                              action: RouteAction.pushNamedAndRemoveUntil,
                            );
                            splashProvider.setPageIndex(0);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ))
                as PreferredSizeWidget?,
        body: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<NotificationProvider>(
              context,
              listen: false,
            ).getNotificationList();
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ResponsiveHelper.isDesktop(context)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeExtraLarge,
                        ),
                        child: Center(
                          child: Text(
                            "notification_list".tr,
                            style: poppinsSemiBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),

              SliverToBoxAdapter(
                child: Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, child) {
                    List<DateTime> dateTimeList = [];

                    return notificationProvider.notificationList != null
                        ? notificationProvider.notificationList!.isNotEmpty
                              ? ListView.builder(
                                  itemCount: notificationProvider
                                      .notificationList!
                                      .length,
                                  padding: ResponsiveHelper.isDesktop(context)
                                      ? const EdgeInsets.symmetric(
                                          horizontal: 350,
                                          vertical: 20,
                                        )
                                      : EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    DateTime originalDateTime =
                                        DateConverterHelper.isoStringToLocalDate(
                                          notificationProvider
                                              .notificationList![index]
                                              .createdAt!,
                                        );
                                    DateTime convertedDate = DateTime(
                                      originalDateTime.year,
                                      originalDateTime.month,
                                      originalDateTime.day,
                                    );
                                    bool addTitle = false;
                                    if (!dateTimeList.contains(convertedDate)) {
                                      addTitle = true;
                                      dateTimeList.add(convertedDate);
                                    }
                                    return NotificationItemWidget(
                                      isTitle: addTitle,
                                      notification: notificationProvider
                                          .notificationList![index],
                                    );
                                  },
                                )
                              : NoDataWidget(
                                  title: getTranslated(
                                    'no_notification_found',
                                    context,
                                  ),
                                )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: CustomLoaderWidget(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                  },
                ),
              ),

              const FooterWebWidget(footerType: FooterType.sliver),
            ],
          ),
        ),
      ),
    );
  }
}
