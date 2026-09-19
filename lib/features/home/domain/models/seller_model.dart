class SellerModel {
  int? _id;
  String? _name;
  String? _slug;
  String? _logo;
  String? _description;
  String? _email;
  String? _phone;
  String? _address;
  String? _city;
  String? _state;
  String? _country;
  String? _zipCode;
  String? _website;
  int? _isFeatured;
  int? _status;
  double? _commissionRate;
  int? _productsCount;
  String? _createdAt;
  String? _updatedAt;

  SellerModel({
    int? id,
    String? name,
    String? slug,
    String? logo,
    String? description,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    String? website,
    int? isFeatured,
    int? status,
    double? commissionRate,
    int? productsCount,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _name = name;
    _slug = slug;
    _logo = logo;
    _description = description;
    _email = email;
    _phone = phone;
    _address = address;
    _city = city;
    _state = state;
    _country = country;
    _zipCode = zipCode;
    _website = website;
    _isFeatured = isFeatured;
    _status = status;
    _commissionRate = commissionRate;
    _productsCount = productsCount;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  int? get id => _id;
  String? get name => _name;
  String? get slug => _slug;
  String? get logo => _logo;
  String? get description => _description;
  String? get email => _email;
  String? get phone => _phone;
  String? get address => _address;
  String? get city => _city;
  String? get state => _state;
  String? get country => _country;
  String? get zipCode => _zipCode;
  String? get website => _website;
  int? get isFeatured => _isFeatured;
  int? get status => _status;
  double? get commissionRate => _commissionRate;
  int? get productsCount => _productsCount;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  // Helper getters
  bool get isActive => _status == 1;
  bool get isFeature => _isFeatured == 1;
  String get logoUrl => _logo ?? '';
  String get fullAddress {
    List<String> parts = [];
    if (_address != null) parts.add(_address!);
    if (_city != null) parts.add(_city!);
    if (_state != null) parts.add(_state!);
    if (_country != null) parts.add(_country!);
    if (_zipCode != null) parts.add(_zipCode!);
    return parts.join(', ');
  }

  SellerModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _slug = json['slug'];
    _logo = json['logo'];
    _description = json['description'];
    _email = json['email'];
    _phone = json['phone'];
    _address = json['address'];
    _city = json['city'];
    _state = json['state'];
    _country = json['country'];
    _zipCode = json['zip_code'];
    _website = json['website'];
    _isFeatured = json['is_featured'];
    _status = json['status'];
    _commissionRate = json['commission_rate']?.toDouble();
    _productsCount = json['products_count'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['slug'] = _slug;
    data['logo'] = _logo;
    data['description'] = _description;
    data['email'] = _email;
    data['phone'] = _phone;
    data['address'] = _address;
    data['city'] = _city;
    data['state'] = _state;
    data['country'] = _country;
    data['zip_code'] = _zipCode;
    data['website'] = _website;
    data['is_featured'] = _isFeatured;
    data['status'] = _status;
    data['commission_rate'] = _commissionRate;
    data['products_count'] = _productsCount;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    return data;
  }
}
