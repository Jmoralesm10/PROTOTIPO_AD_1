import 'package:file_picker/file_picker.dart' as fp;
import 'platform_file.dart' as custom;
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

Future<custom.PlatformFile?> pickFile() async {
  fp.FilePickerResult? result = await fp.FilePicker.platform.pickFiles(
    type: fp.FileType.custom,
    allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
  );

  if (result != null) {
    if (kIsWeb) {
      // Para web
      return custom.WebFile(
        result.files.single.name,
        result.files.single.bytes!,
        result.files.single.name,
      );
    } else {
      // Para plataformas móviles
      return custom.MobileFile(File(result.files.single.path!));
    }
  }
  return null;
}
