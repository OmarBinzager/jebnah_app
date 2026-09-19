import 'package:flutter/material.dart';
import '../../../helper/file_validation_helper.dart';
import 'package:image_picker/image_picker.dart';

class OrderImageNoteProvider extends ChangeNotifier {
  List<XFile?>? _imageFiles;

  List<XFile?>? get imageFiles => _imageFiles;

  void onPickImage(
    BuildContext context,
    bool isRemove, {
    bool fromCamera = false,
    bool isUpdate = true,
  }) async {
    if (isRemove) {
      _imageFiles = [];
    } else {
      if (fromCamera) {
        final pickedImage = await FileValidationHelper.validateAndPickImage(
          context: context,
          source: ImageSource.camera,
        );

        if (pickedImage != null) {
          _imageFiles?.add(pickedImage);
        }
      } else {
        _imageFiles = await FileValidationHelper.validateAndPickMultipleImages(
          context: context,
        );
      }
    }

    if (isUpdate) {
      notifyListeners();
    }
  }

  void removeImage(int index) {
    _imageFiles?.removeAt(index);
    notifyListeners();
  }
}
