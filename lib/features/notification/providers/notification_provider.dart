import 'package:flutter/material.dart';
import '../../../common/models/api_response_model.dart';
import '../../../features/notification/domain/models/notification_model.dart';
import '../../../features/notification/domain/reposotories/notification_repo.dart';
import '../../../helper/api_checker_helper.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepo? notificationRepo;
  NotificationProvider({required this.notificationRepo});

  List<NotificationModel>? _notificationList;
  List<NotificationModel>? get notificationList => _notificationList != null
      ? _notificationList!.reversed.toList()
      : _notificationList;

  Future<void> getNotificationList({bool isUpdate = true}) async {
    _notificationList = null;

    if (isUpdate) {
      notifyListeners();
    }

    ApiResponseModel apiResponse = await notificationRepo!
        .getNotificationList();
    if (apiResponse.response?.statusCode == 200) {
      _notificationList = [];
      apiResponse.response!.data.forEach(
        (notificationModel) => _notificationList!.add(
          NotificationModel.fromJson(notificationModel),
        ),
      );
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }
}
