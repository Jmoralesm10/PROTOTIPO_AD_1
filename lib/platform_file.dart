import 'dart:io' show File;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

abstract class PlatformFile {
  String get path;
  Future<Uint8List> readAsBytes();
}

class MobileFile extends PlatformFile {
  final File file;
  MobileFile(this.file);
  @override
  String get path => file.path;
  @override
  Future<Uint8List> readAsBytes() => file.readAsBytes();
}

class WebFile extends PlatformFile {
  final String webPath;
  WebFile(this.webPath);
  @override
  String get path => webPath;
  @override
  Future<Uint8List> readAsBytes() async {
    final response = await http.get(Uri.parse(webPath));
    return response.bodyBytes;
  }
}
