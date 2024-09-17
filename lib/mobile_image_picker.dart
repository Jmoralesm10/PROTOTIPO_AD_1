import 'package:image_picker/image_picker.dart';
import 'package:prototipo_asambleas_1/platform_file.dart';
import 'dart:io';

Future<PlatformFile?> getWebImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    return MobileFile(File(pickedFile.path));
  }
  return null;
}
