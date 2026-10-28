/// errors : [{"code":"l_name","message":"The last name field is required."},{"code":"password","message":"The password field is required."}]
library;

class ErrorResponseModel {
  List<Errors>? _errors;

  List<Errors>? get errors => _errors;

  ErrorResponseModel({List<Errors>? errors}) {
    _errors = errors;
  }

  ErrorResponseModel.fromJson(dynamic json) {
    if (json == null) return;
    _errors = [];

    if (json is Map) {
      if (json['errors'] != null) {
        if (json['errors'] is List) {
          json['errors'].forEach((v) {
            _errors!.add(Errors.fromJson(v));
          });
        } else if (json['errors'] is Map) {
          (json['errors'] as Map).forEach((key, val) {
            if (val is List && val.isNotEmpty) {
              _errors!.add(Errors(code: key.toString(), message: val.first.toString()));
            } else if (val != null) {
              _errors!.add(Errors(code: key.toString(), message: val.toString()));
            }
          });
        } else if (json['errors'] is String) {
          _errors!.add(Errors(code: '', message: json['errors'].toString()));
        }
      } else if (json['message'] != null) {
        _errors!.add(
          Errors(
            code: json['code']?.toString() ?? '',
            message: json['message'].toString(),
          ),
        );
      }
    } else if (json is List) {
      for (var v in json) {
        if (v is Map) {
          _errors!.add(Errors.fromJson(v));
        } else if (v is String) {
          _errors!.add(Errors(code: '', message: v));
        }
      }
    } else if (json is String) {
      _errors!.add(Errors(code: '', message: json));
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_errors != null) {
      map["errors"] = _errors!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// code : "l_name"
/// message : "The last name field is required."

class Errors {
  String? _code;
  String? _message;

  String? get code => _code;
  String? get message => _message;

  Errors({String? code, String? message}) {
    _code = code;
    _message = message;
  }

  Errors.fromJson(dynamic json) {
    if (json is Map) {
      _code = json["code"]?.toString() ?? json["key"]?.toString() ?? json["error_code"]?.toString();
      _message = json["message"]?.toString() ?? json["error"]?.toString() ?? json["error_message"]?.toString() ?? json["detail"]?.toString();
      if (_message == null) {
        for (var entry in json.entries) {
          if (entry.value != null && entry.value.toString().isNotEmpty) {
            _code ??= entry.key.toString();
            _message = entry.value is List
                ? (entry.value as List).first.toString()
                : entry.value.toString();
            break;
          }
        }
      }
    } else if (json is String) {
      _message = json;
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["code"] = _code;
    map["message"] = _message;
    return map;
  }
}
