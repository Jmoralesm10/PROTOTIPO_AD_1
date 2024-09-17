import 'dart:html' as html;
import 'dart:typed_data';
import 'package:prototipo_asambleas_1/platform_file.dart';

Future<PlatformFile?> getWebImage() async {
  final html.FileUploadInputElement input = html.FileUploadInputElement()
    ..accept = 'image/*';
  input.click();

  await input.onChange.first;
  if (input.files!.isNotEmpty) {
    final file = input.files!.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    final result = reader.result;
    if (result is List<int>) {
      final uint8List = Uint8List.fromList(result);
      return WebFile(html.Url.createObjectUrlFromBlob(file));
    }
  }
  return null;
}
