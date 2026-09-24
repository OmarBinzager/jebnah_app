import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../common/enums/notification_type.dart';
import '../common/models/notification_body.dart';
import '../features/splash/providers/splash_provider.dart';
import '../helper/maintenance_helper.dart';
import '../helper/route_helper.dart';
import '../main.dart';
import '../utill/app_constants.dart';
import '../common/widgets/notification_dialog_web_widget.dart';

import 'package:provider/provider.dart';

class NotificationHelper {
  // تم إزالة معامل FlutterLocalNotificationsPlugin من الدالة initialize
  static Future<void> initialize() async {
    // تم حذف: تهيئة flutter_local_notifications بالكامل

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print(
          "onMessage: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}",
        );
        print('id ${message.data}');
      }

      if (message.data['type'] == 'maintenance') {
        final SplashProvider splashProvider = Provider.of<SplashProvider>(
          Get.context!,
          listen: false,
        );
        await splashProvider.initConfig(Get.context!, fromNotification: true);
      }

      if (message.data['type'] != 'maintenance') {
        // تم تعديل: تمرير true للـ isWeb فقط، وإزالة معامل flutterLocalNotificationsPlugin
        showNotification(message, kIsWeb);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print(
          "onOpenApp: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}",
        );
      }

      if (message.data['type'] == 'maintenance') {
        final SplashProvider splashProvider = Provider.of<SplashProvider>(
          Get.context!,
          listen: false,
        );
        await splashProvider.initConfig(Get.context!, fromNotification: true);
        if (MaintenanceHelper.isMaintenanceModeEnable(
              splashProvider.configModel,
            ) &&
            (MaintenanceHelper.checkCustomerMaintenanceMode(
                  splashProvider.configModel,
                ) ||
                MaintenanceHelper.checkWebMaintenanceMode(
                  splashProvider.configModel,
                ))) {
          RouteHelper.getMaintenanceRoute(
            action: RouteAction.pushNamedAndRemoveUntil,
          );
        } else if (!MaintenanceHelper.isMaintenanceModeEnable(
              splashProvider.configModel,
            ) &&
            ModalRoute.of(Get.context!)?.settings.name ==
                RouteHelper.maintenance) {
          RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
        }
      }

      final NotificationBody notificationBody =
          NotificationHelper.convertNotification(message.data);
      NotificationType? notificationType = getNotificationTypeEnum(
        notificationBody.type,
      );

      switch (notificationType) {
        case NotificationType.order:
          RouteHelper.getOrderDetailsRoute(
            notificationBody.orderId.toString(),
            action: RouteAction.pushNamedAndRemoveUntil,
          );
          break;
        case NotificationType.message:
          RouteHelper.getChatRoute(
            orderId: notificationBody.orderId.toString(),
            senderType: notificationBody.senderType ?? "admin",
            profileImage: notificationBody.userImage ?? "",
            userName: notificationBody.userName ?? "",
            isAppBar: true,
            action: RouteAction.pushNamedAndRemoveUntil,
          );
          break;
        case NotificationType.general:
          RouteHelper.getNotificationScreen(
            action: RouteAction.pushNamedAndRemoveUntil,
          );
          break;
        case NotificationType.wallet:
          RouteHelper.getWalletRoute(
            status: '',
            action: RouteAction.pushNamedAndRemoveUntil,
          );
          break;
        case null:
          debugPrint(
            '==============Notification type does not exist============${notificationBody.type}',
          );
          RouteHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
      }
    });
  }

  static Future<void> showNotification(
    RemoteMessage message,
    bool isWeb, // تم تغيير اسم المعامل من data إلى isWeb للتوضيح
  ) async {
    String? title;
    String? body;
    String? orderID;
    String? image;
    String? type;
    String? userName;
    String? senderType;
    String? profileImage;

    title = message.notification?.title ?? message.data['title'];
    body = message.notification?.body ?? message.data['body'];
    orderID = message.data['order_id'];
    userName = message.data['name'];
    senderType = message.data['sender_type'];
    profileImage = message.data['profile_image'];
    image = (message.notification?.android?.imageUrl != null &&
            message.notification!.android!.imageUrl!.isNotEmpty)
        ? message.notification!.android!.imageUrl
        : (message.data['image'] != null && message.data['image'].isNotEmpty)
            ? message.data['image'].startsWith('http')
                ? message.data['image']
                : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}'
            : null;
    type = message.data['type'];

    if (Get.context != null && (title != null || body != null)) {
      showDialog(
        context: Get.context!,
        builder: (context) => Center(
          child: NotificationDialogWebWidget(
            orderId: int.tryParse(orderID ?? '0'),
            title: title,
            body: body,
            image: image,
            type: type,
            userName: userName,
            profileImage: profileImage,
            senderType: senderType,
          ),
        ),
      );
    } else {
      if (kDebugMode) {
        print(
          'Notification received: $title - $body (type: $type)',
        );
      }
    }
  }

  // تم حذف الدوال التالية بالكامل لأنها تعتمد على flutter_local_notifications:
  // - showBigTextNotification
  // - showBigPictureNotificationHiddenLargeIcon
  // - _downloadAndSaveFile

  static NotificationBody convertNotification(Map<String, dynamic> data) {
    return NotificationBody.fromJson(data);
  }
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print(
      "onBackground: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}",
    );
  }
  // تم حذف: أي كود كان يعتمد على flutter_local_notifications في الخلفية
}
