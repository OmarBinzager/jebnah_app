import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends InterceptorsWrapper {
  int maxCharactersPerLine = 200;

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (kDebugMode) {
      print("--> ${options.method} ${options.path}");
      print("Headers: ${options.headers.toString()}");
      print("<-- END HTTP");
    }

    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (kDebugMode) {
      print("<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}");
    }

    // Detect HTML responses that should be JSON — reject them before they
    // propagate into the app and appear as raw HTML text in error messages.
    final contentType = response.headers.value('content-type') ?? '';
    final isHtmlContentType = contentType.contains('text/html');
    final dataStr = response.data is String ? (response.data as String).trimLeft() : '';
    final startsWithHtml = dataStr.startsWith('<!') ||
        dataStr.toLowerCase().startsWith('<html') ||
        dataStr.startsWith('<?xml');

    if (isHtmlContentType || startsWithHtml) {
      if (kDebugMode) {
        print(
          'LoggingInterceptor: HTML response detected for ${response.requestOptions.path}. '
          'Expected JSON. Rejecting response.',
        );
      }
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message:
              'Server returned an HTML page instead of JSON. '
              'The API endpoint may be unavailable or redirecting to the website.',
        ),
      );
    }

    String responseAsString = response.data.toString();
    if (responseAsString.length > maxCharactersPerLine) {
      int iterations = (responseAsString.length / maxCharactersPerLine).floor();
      for (int i = 0; i <= iterations; i++) {
        int endingIndex = i * maxCharactersPerLine + maxCharactersPerLine;
        if (endingIndex > responseAsString.length) {
          endingIndex = responseAsString.length;
        }
      }
    }

    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      print("ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}");
    }
    return super.onError(err, handler);
  }
}
