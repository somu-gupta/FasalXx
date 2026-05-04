import 'dart:typed_data';

class SelectedImage {
  const SelectedImage({
    required this.name,
    required this.bytes,
  });

  final String name;
  final Uint8List bytes;
}

Future<SelectedImage?> pickChatImage() async {
  return null;
}
