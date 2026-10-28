import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../common/models/error_response_model.dart';

class ApiErrorHandler {
  static dynamic getMessage(error) {
    dynamic errorDescription = "";
    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              errorDescription = "Request to API server was cancelled";
              break;

            case DioExceptionType.receiveTimeout:
              errorDescription =
                  "Receive timeout in connection with API server";
              break;
            case DioExceptionType.badResponse:
              switch (error.response!.statusCode) {
                case 500:
                case 503:
                  errorDescription = error.response!.statusMessage;
                  break;
                default:
                  ErrorResponseModel? errorResponse;
                  try {
                    errorResponse = ErrorResponseModel.fromJson(
                      error.response!.data,
                    );
                  } catch (e) {
                    if (kDebugMode) {
                      print('error is -> ${e.toString()}');
                    }
                  }

                  if (errorResponse != null &&
                      errorResponse.errors != null &&
                      errorResponse.errors!.isNotEmpty &&
                      errorResponse.errors![0].message != null &&
                      errorResponse.errors![0].message!.trim().isNotEmpty &&
                      errorResponse.errors![0].message != 'null') {
                    if (kDebugMode) {
                      print(
                        'error----------------== ${errorResponse.errors![0].message} || error: ${error.response!.requestOptions.uri}',
                      );
                    }
                    errorDescription = errorResponse.toJson();
                  } else {
                    errorDescription =
                        "Failed to load data - status code: ${error.response!.statusCode}";
                  }
              }
              break;
            case DioExceptionType.sendTimeout:
              errorDescription = 'send_timeout_with_server';
              break;
            case DioExceptionType.connectionTimeout:
              errorDescription = 'send_timeout_with_server';
              break;
            case DioExceptionType.badCertificate:
              errorDescription = 'incorrect_certificate';
              break;
            case DioExceptionType.connectionError:
              errorDescription = 'unavailable_to_process_data';
              break;
            case DioExceptionType.unknown:
              debugPrint(
                'error----------------== ${error.response?.requestOptions.path} || ${error.response?.statusCode} ${error.response?.data}',
              );

              errorDescription = 'unavailable_to_process_data';
              break;
          }
        } else {
          errorDescription = "Unexpected error occured";
        }
      } on FormatException catch (e) {
        errorDescription = e.toString();
      }
    } else {
      errorDescription = "is not a subtype of exception";
    }
    return errorDescription;
  }
}
