class BannerModel {
  int? _id;
  String? _title;
  String? _image;
  int? _productId;
  int? _status;
  String? _createdAt;
  String? _updatedAt;
  int? _categoryId;
  // الحقول الجديدة التي أضيفت بناءً على الـ API الخاص بك
  String? _displayType;
  int? _sortOrder;
  String? _clickAction;
  String? _externalLink;
  String? _sections;
  String? _productIds;
  String? _categoryIds;
  String? _scrollDirection;

  BannerModel({
    int? id,
    String? title,
    String? image,
    int? productId,
    int? status,
    String? createdAt,
    String? updatedAt,
    int? categoryId,
    String? displayType,
    int? sortOrder,
    String? clickAction,
    String? externalLink,
    String? sections,
    String? productIds,
    String? categoryIds,
    String? scrollDirection,
  }) {
    _id = id;
    _title = title;
    _image = image;
    _productId = productId;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _categoryId = categoryId;
    _displayType = displayType;
    _sortOrder = sortOrder;
    _clickAction = clickAction;
    _externalLink = externalLink;
    _sections = sections;
    _productIds = productIds;
    _categoryIds = categoryIds;
    _scrollDirection = scrollDirection;
  }

  int? get id => _id;
  String? get title => _title;
  String? get image => _image;
  int? get productId => _productId;
  int? get status => _status;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get categoryId => _categoryId;
  // الـ Getters للحقول الجديدة
  String? get displayType => _displayType;
  int? get sortOrder => _sortOrder;
  String? get clickAction => _clickAction;
  String? get externalLink => _externalLink;
  String? get sections => _sections;
  String? get productIds => _productIds;
  String? get categoryIds => _categoryIds;
  String? get scrollDirection => _scrollDirection;

  BannerModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _title = json['title'];
    _image = json['image'];
    _productId = json['product_id'] != null
        ? int.parse(json['product_id'].toString())
        : null;
    _status = json['status'] != null
        ? int.parse(json['status'].toString())
        : null;
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _categoryId = json['category_id'] != null
        ? int.parse(json['category_id'].toString())
        : null;
    // تحويل البيانات الجديدة من الـ JSON
    _displayType = json['display_type'];
    _sortOrder = json['sort_order'] != null
        ? int.parse(json['sort_order'].toString())
        : null;
    _clickAction = json['click_action'];
    _externalLink = json['external_link'];
    _sections = json['sections'];
    _productIds = json['product_ids'];
    _categoryIds = json['category_ids'];
    _scrollDirection = json['scroll_direction'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['title'] = _title;
    data['image'] = _image;
    data['product_id'] = _productId;
    data['status'] = _status;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['category_id'] = _categoryId;
    // تحويل البيانات الجديدة إلى JSON عند الحاجة للرفع
    data['display_type'] = _displayType;
    data['sort_order'] = _sortOrder;
    data['click_action'] = _clickAction;
    data['external_link'] = _externalLink;
    data['sections'] = _sections;
    data['product_ids'] = _productIds;
    data['category_ids'] = _categoryIds;
    data['scroll_direction'] = _scrollDirection;
    return data;
  }
}
