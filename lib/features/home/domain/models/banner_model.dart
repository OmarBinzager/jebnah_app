import 'dart:convert';

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
  List<String>? _sections;
  List<String>? _productIds;
  List<String>? _categoryIds;
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
    dynamic sections,
    dynamic productIds,
    dynamic categoryIds,
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
    _sections = _parseList(sections);
    _productIds = _parseList(productIds);
    _categoryIds = _parseList(categoryIds);
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
  List<String>? get sections => _sections;
  List<String>? get productIds => _productIds;
  List<String>? get categoryIds => _categoryIds;
  List<int>? get productIdsAsInt =>
      _productIds?.map((e) => int.tryParse(e)).whereType<int>().toList();
  List<int>? get categoryIdsAsInt =>
      _categoryIds?.map((e) => int.tryParse(e)).whereType<int>().toList();
  String? get scrollDirection => _scrollDirection;

  static List<String>? _parseList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return [];
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
      if (trimmed.contains(',')) {
        return trimmed
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [trimmed];
    }
    return null;
  }

  BannerModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    _title = json['title']?.toString();
    _image = json['image']?.toString();
    _productId = json['product_id'] != null
        ? int.tryParse(json['product_id'].toString())
        : null;
    _status = json['status'] != null
        ? int.tryParse(json['status'].toString())
        : null;
    _createdAt = json['created_at']?.toString();
    _updatedAt = json['updated_at']?.toString();
    _categoryId = json['category_id'] != null
        ? int.tryParse(json['category_id'].toString())
        : null;
    // تحويل البيانات الجديدة من الـ JSON
    _displayType = json['display_type']?.toString();
    _sortOrder = json['sort_order'] != null
        ? int.tryParse(json['sort_order'].toString())
        : null;
    _clickAction = json['click_action']?.toString();
    _externalLink = json['external_link']?.toString();
    _sections = _parseList(json['sections']);
    _productIds = _parseList(json['product_ids']);
    _categoryIds = _parseList(json['category_ids']);
    _scrollDirection = json['scroll_direction']?.toString();
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
