import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class SelectedImage {
  const SelectedImage({
    required this.name,
    required this.bytes,
  });

  final String name;
  final Uint8List bytes;
}

final ImagePicker _picker = ImagePicker();

Future<SelectedImage?> pickChatImage() async {
  return pickDeviceImage();
}

Future<SelectedImage?> pickDeviceImage({bool fromCamera = false}) async {
  XFile? file;

  try {
    file = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 86,
    );
  } catch (_) {
    if (!fromCamera) {
      rethrow;
    }

    file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 86,
    );
  }

  if (file == null) {
    return null;
  }

  return SelectedImage(
    name: file.name,
    bytes: await file.readAsBytes(),
  );
}
