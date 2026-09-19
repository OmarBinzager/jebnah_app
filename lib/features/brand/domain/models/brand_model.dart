class BrandModel {
  int? _id;
  String? _name;
  String? _slug;
  String? _description;
  String? _image;
  int? _isFeatured;
  int? _status;
  int? _productsCount;
  String? _createdAt;
  String? _updatedAt;

  BrandModel({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? image,
    int? isFeatured,
    int? status,
    int? productsCount,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _name = name;
    _slug = slug;
    _description = description;
    _image = image;
    _isFeatured = isFeatured;
    _status = status;
    _productsCount = productsCount;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  int? get id => _id;
  String? get name => _name;
  String? get slug => _slug;
  String? get description => _description;
  String? get image => _image;
  int? get isFeatured => _isFeatured;
  int? get status => _status;
  int? get productsCount => _productsCount;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  // Helper getters
  bool get isActive => _status == 1;
  bool get isFeature => _isFeatured == 1;
  String get imageUrl => _image ?? '';

  BrandModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _slug = json['slug'];
    _description = json['description'];
    _image = json['image'];
    _isFeatured = json['is_featured'];
    _status = json['status'];
    _productsCount = json['products_count'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['slug'] = _slug;
    data['description'] = _description;
    data['image'] = _image;
    data['is_featured'] = _isFeatured;
    data['status'] = _status;
    data['products_count'] = _productsCount;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    return data;
  }
}
