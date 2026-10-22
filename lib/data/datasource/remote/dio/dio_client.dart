import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../data/datasource/remote/dio/logging_interceptor.dart';
import '../../../../utill/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  final String baseUrl;
  final LoggingInterceptor loggingInterceptor;
  final SharedPreferences sharedPreferences;

  Dio? dio;
  String? token;

  DioClient(this.baseUrl,
      Dio? dioC, {
        required this.loggingInterceptor,
        required this.sharedPreferences,
      }) {
    final savedToken = sharedPreferences.getString(AppConstants.token);
    token = (savedToken != null && savedToken.trim().isNotEmpty && savedToken != 'null')
        ? savedToken.trim()
        : null;
    dio = dioC ?? Dio();

    updateHeader(dioC: dioC, getToken: token);
  }

  Future<void> updateHeader({
    String? getToken,
    Dio? dioC,
    String? languageCode,
    String? currencyCode,
    bool isClear = false,
  }) async {
    if (isClear) {
      token = null;
    } else if (getToken != null) {
      final clean = getToken.trim();
      token = (clean.isNotEmpty && clean != 'null') ? clean : null;
    } else {
      final savedToken = sharedPreferences.getString(AppConstants.token)?.trim();
      token = (savedToken != null && savedToken.isNotEmpty && savedToken != 'null') ? savedToken : null;
    }

    final Map<String, dynamic> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'X-localization': languageCode ?? sharedPreferences.getString(AppConstants.languageCode)
          ?? AppConstants.languages[0].languageCode,
      'X-Currency-Code': currencyCode ?? sharedPreferences.getString(AppConstants.currency) ?? 'YER',
      'guest-id': sharedPreferences.getString(AppConstants.guestId) ?? '',
    };

    if (token != null && token!.isNotEmpty && token != 'null') {
      final parts = token!.split('.');
      if (parts.length == 3) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    dio?..options.baseUrl = baseUrl
      ..options.connectTimeout = const Duration(seconds: 45)
      ..options.receiveTimeout = const Duration(seconds: 45)
      ..httpClientAdapter
      ..options.headers = headers;

    if (dio != null && !dio!.interceptors.contains(loggingInterceptor)) {
      dio!.interceptors.add(loggingInterceptor);
    }
  }

  Future<Response> get(String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await dio!.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on SocketException catch (e) {

      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      if (kDebugMode) {
        print('===============${e.toString()}');
      }
      rethrow;
    }
  }

  Future<Response> post(String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    debugPrint('apiCall ==> url=> $uri \nparams---> $queryParameters\nheader=> ${dio!.options.headers}\nbody=> $data');

    try {
      var response = await dio!.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> postMultipart(String uri, {
    Map<String, dynamic>? data,
    List<XFile?>? files,
    String? fileKey,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (files == null || files.isEmpty) {
      return await post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    }

    debugPrint('apiCall ==> url=> $uri \nparams---> $queryParameters\nheader=> ${dio!.options.headers}');

    try{
      List<MultipartFile> fileList = [];

      for(int i = 0; i < files.length; i++) {
        if (files[i] != null) {
          fileList.add(MultipartFile.fromBytes(
            await files[i]!.readAsBytes(),
            filename: files[i]!.name,
          ));
        }
      }

      if(fileList.isNotEmpty) {
        data?.addAll({
          '${fileKey ?? 'image'}[]' : fileList,
        });
      }

    }catch(e) {
      rethrow;
    }




    try {
      var response = await dio!.post(
        uri,
        data: FormData.fromMap(data ?? {}),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }
  Future<Response> put(String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await dio!.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      var response = await dio!.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

}
