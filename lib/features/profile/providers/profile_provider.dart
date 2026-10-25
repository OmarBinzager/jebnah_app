import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../common/models/api_response_model.dart';

import '../../../common/models/response_model.dart';
import '../../../features/profile/domain/models/userinfo_model.dart';
import '../../../features/profile/domain/reposotories/profile_repo.dart';
import '../../../helper/api_checker_helper.dart';
import '../../../helper/file_validation_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../main.dart';
import '../../../utill/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepo? profileRepo;

  ProfileProvider({required this.profileRepo});

  UserInfoModel? _userInfoModel;
  bool _isLoading = false;
  File? _file;
  PickedFile? _data;
  String? _countryCode;
  final List<String?> hintList = [
    getTranslated('invite_your_friends', Get.context!),
    '${getTranslated('they_register', Get.context!)} ${AppConstants.appName} ${getTranslated('with_special_offer', Get.context!)}',
    getTranslated('you_made_your_earning', Get.context!),
  ];
  UserInfoModel? get userInfoModel => _userInfoModel;
  String? get countryCode => _countryCode;
  bool get isLoading => _isLoading;
  PickedFile? get data => _data;
  File? get file => _file;

  final picker = ImagePicker();

  Future<void> getUserInfo(bool reload, {bool isUpdate = true}) async {
    _isLoading = true;
    if (reload) {
      _userInfoModel = null;
    }

    if (_userInfoModel == null) {
      ApiResponseModel apiResponse = await profileRepo!.getUserInfo();
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        _userInfoModel = UserInfoModel.fromJson(apiResponse.response!.data);
      } else {
        ApiCheckerHelper.checkApi(apiResponse);
      }
    }

    _isLoading = false;
    if (isUpdate) {
      notifyListeners();
    }
  }

  Future<void> choosePhoto(BuildContext context) async {
    final pickedFile = await FileValidationHelper.validateAndPickImage(
      context: context,
      source: ImageSource.gallery,
      maxHeight: 500,
      maxWidth: 500,
    );

    if (pickedFile != null) {
      _file = File(pickedFile.path);
    }
    notifyListeners();
  }

  Future<void> pickImage(BuildContext context) async {
    final pickedFile = await FileValidationHelper.validateAndPickImage(
      context: context,
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      _data = PickedFile(pickedFile.path);
    }
    notifyListeners();
  }

  Future<ResponseModel> updateUserInfo(
    UserInfoModel updateUserModel,
    String pass,
    File? file,
    PickedFile? data,
    String token,
  ) async {
    _isLoading = true;
    notifyListeners();

    ResponseModel responseModel;
    http.StreamedResponse response = await profileRepo!.updateProfile(
      updateUserModel,
      pass,
      file,
      data,
      token,
    );
    if (response.statusCode == 200) {
      Map map = jsonDecode(await response.stream.bytesToString());
      String? message = map["message"];
      _userInfoModel = updateUserModel;
      responseModel = ResponseModel(true, message);
    } else {
      responseModel = ResponseModel(
        false,
        await ApiCheckerHelper.getStreamedResponseError(response),
      );
    }

    _isLoading = false;
    notifyListeners();

    return responseModel;
  }

  void setCountryCode(String countryCode, {bool isUpdate = true}) {
    _countryCode = countryCode;
    if (isUpdate) {
      notifyListeners();
    }
  }
}
