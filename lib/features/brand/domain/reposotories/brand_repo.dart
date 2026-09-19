import '../../../../common/enums/data_source_enum.dart';
import '../../../../common/reposotories/data_sync_repo.dart';
import '../../../../data/datasource/remote/exception/api_error_handler.dart';
import '../../../../common/models/api_response_model.dart';
import '../../../../utill/app_constants.dart';

class BrandRepo extends DataSyncRepo {
  BrandRepo({required super.dioClient, required super.sharedPreferences});

  Future<ApiResponseModel<T>> getBrandList<T>({
    required DataSourceEnum source,
  }) async {
    return await fetchData<T>(AppConstants.brandUri, source);
  }

  Future<ApiResponseModel<T>> getFeaturedBrands<T>({
    required DataSourceEnum source,
  }) async {
    return await fetchData<T>(AppConstants.featuredBrandUri, source);
  }

  Future<ApiResponseModel> getBrandDetails(String brandId) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.brandDetailsUri}$brandId',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getBrandProducts(
    String brandId, {
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.brandProductsUri}$brandId/products?page=$page&limit=$limit',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
