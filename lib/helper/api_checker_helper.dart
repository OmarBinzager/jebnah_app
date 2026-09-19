import 'dart:convert';

import 'package:flutter/material.dart';
import '../common/models/api_response_model.dart';
import '../common/models/error_response_model.dart';
import '../helper/route_helper.dart';
import '../localization/language_constraints.dart';
import '../main.dart';
import '../features/splash/providers/splash_provider.dart';
import '../helper/custom_snackbar_helper.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ApiCheckerHelper {
  static void checkApi(ApiResponseModel apiResponse) {
    ErrorResponseModel error = getError(apiResponse);

    if (error.errors != null &&
        error.errors!.isNotEmpty &&
        (error.errors![0].code == '401' || error.errors![0].code == 'auth-001') &&
        ModalRoute.of(Get.context!)?.settings.name != RouteHelper.login) {
      Provider.of<SplashProvider>(
        Get.context!,
        listen: false,
      ).removeSharedData();
      RouteHelper.getLoginRoute(action: RouteAction.pushNamedAndRemoveUntil);
    } else {
      String? errorMessage;
      if (error.errors != null && error.errors!.isNotEmpty) {
        errorMessage = error.errors!.first.message;
      }
      if (errorMessage == null || errorMessage.trim().isEmpty) {
        errorMessage = 'something_went_wrong';
      }
      showCustomSnackBarHelper(
        getTranslated(errorMessage, Get.context!),
      );
    }
  }

  static ErrorResponseModel getError(ApiResponseModel apiResponse) {
    ErrorResponseModel error;

    try {
      if (apiResponse.response != null && apiResponse.response?.data != null) {
        error = ErrorResponseModel.fromJson(apiResponse.response?.data);
      } else if (apiResponse.error != null) {
        error = ErrorResponseModel.fromJson(apiResponse.error);
      } else {
        error = ErrorResponseModel(
          errors: [Errors(code: '', message: 'something_went_wrong')],
        );
      }
    } catch (e) {
      error = ErrorResponseModel(
        errors: [
          Errors(
            code: '',
            message: apiResponse.error?.toString() ?? 'something_went_wrong',
          ),
        ],
      );
    }

    if (error.errors == null || error.errors!.isEmpty) {
      error = ErrorResponseModel(
        errors: [Errors(code: '', message: 'something_went_wrong')],
      );
    }

    return error;
  }

  static Future<String> getStreamedResponseError(
    http.StreamedResponse response,
  ) async {
    String errorMessage = '${response.statusCode} ${response.reasonPhrase}';

    try {
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> responseMap = jsonDecode(responseBody);

      ErrorResponseModel errorResponse = ErrorResponseModel.fromJson(
        responseMap,
      );

      if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
        errorMessage = errorResponse.errors!.first.message ?? errorMessage;
      }
    } catch (e) {
      debugPrint('Error parsing response: $e');
    }

    return errorMessage;
  }
}
