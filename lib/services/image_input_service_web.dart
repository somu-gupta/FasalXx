import 'dart:async';
import 'dart:html' as html;
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
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false;

  input.click();
  await input.onChange.first;

  final file = input.files?.isNotEmpty == true ? input.files!.first : null;
  if (file == null) {
    return null;
  }

  final reader = html.FileReader();
  reader.readAsArrayBuffer(file);
  await reader.onLoad.first;

  final result = reader.result;
  if (result is ByteBuffer) {
    return SelectedImage(name: file.name, bytes: Uint8List.view(result));
  }
  if (result is Uint8List) {
    return SelectedImage(name: file.name, bytes: result);
  }

  return null;
}
