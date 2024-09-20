import 'dart:io' show File;
import 'dart:typed_data';

abstract class PlatformFile {
  String get path;
  String get name;
  Future<Uint8List> readAsBytes();
}

class MobileFile extends PlatformFile {
  final File file;
  MobileFile(this.file);
  @override
  String get path => file.path;
  @override
  String get name => file.path.split('/').last;
  @override
  Future<Uint8List> readAsBytes() => file.readAsBytes();
}

class WebFile extends PlatformFile {
  final String webPath;
  final Uint8List bytes;
  final String fileName;
  WebFile(this.webPath, this.bytes, this.fileName);
  @override
  String get path => webPath;
  @override
  String get name => fileName;
  @override
  Future<Uint8List> readAsBytes() async => bytes;
}
