import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../localization/app_localization.dart';

String getTranslated(String? key, BuildContext context) {
  if (key == null || key.isEmpty) return '';
  String? text = key;
  try {
    text = AppLocalization.of(context)!.translate(key);
  } catch (error) {
    if (kDebugMode) {
      print('not localized --- $error');
    }
  }
  return text ?? key;
}
