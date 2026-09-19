import '../../../../common/models/product_model.dart';

class CategoryProductModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<Product>? products;

  CategoryProductModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.products,
  });

  CategoryProductModel.fromJson(Map<String, dynamic> json) {
    totalSize = int.tryParse(json['total_size'].toString());
    limit = int.tryParse(json['limit'].toString());
    offset = int.tryParse(json['offset'].toString());
    if (json['products'] != null) {
      products = <Product>[];
      json['products'].forEach((v) {
        products!.add(Product.fromJson(v));
      });
    }
  }
}
