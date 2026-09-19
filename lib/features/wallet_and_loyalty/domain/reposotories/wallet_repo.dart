import '../../../../data/datasource/remote/dio/dio_client.dart';
import '../../../../data/datasource/remote/exception/api_error_handler.dart';
import '../../../../common/models/api_response_model.dart';
import '../../../../utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;

  WalletRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponseModel> getWalletTransactionList(
    String offset,
    String type,
  ) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.walletTransactionUrl}?offset=$offset&limit=10&transaction_type=$type',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getLoyaltyTransactionList(
    String offset,
    String type,
  ) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.loyaltyTransactionUrl}?offset=$offset&limit=10&type=$type',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> pointToWallet({int? point}) async {
    try {
      final response = await dioClient!.post(
        AppConstants.loyaltyPointTransferUrl,
        data: {'point': point},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getWalletBonusList() async {
    try {
      final response = await dioClient!.get(AppConstants.walletBonusListUrl);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getAddFundUrl({
    required final int? customerId,
    required final String? paymentMethod,
    required final String? paymentPlatform,
    required final double? amount,
    required final String? callback,
  }) async {
    try {
      final response = await dioClient!.post(
        AppConstants.addFundWallet,
        data: {
          'customer_id': customerId,
          'payment_method': paymentMethod,
          'payment_platform': paymentPlatform,
          'amount': amount,
          'call_back': callback,
        },
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
