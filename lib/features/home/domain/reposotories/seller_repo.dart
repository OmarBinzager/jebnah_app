import '../../../../common/enums/data_source_enum.dart';
import '../../../../common/reposotories/data_sync_repo.dart';
import '../../../../data/datasource/remote/exception/api_error_handler.dart';
import '../../../../common/models/api_response_model.dart';
import '../../../../utill/app_constants.dart';

class SellerRepo extends DataSyncRepo {
  SellerRepo({required super.dioClient, required super.sharedPreferences});

  Future<ApiResponseModel<T>> getSellerList<T>({
    required DataSourceEnum source,
  }) async {
    return await fetchData<T>(AppConstants.sellerUri, source);
  }

  Future<ApiResponseModel<T>> getFeaturedSellers<T>({
    required DataSourceEnum source,
  }) async {
    return await fetchData<T>(AppConstants.featuredSellerUri, source);
  }

  Future<ApiResponseModel> getSellerDetails(String sellerId) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.sellerDetailsUri}$sellerId',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getSellerProducts(String sellerId, {int page = 1, int limit = 15}) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.sellerProductsUri}$sellerId/products?page=$page&limit=$limit',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}