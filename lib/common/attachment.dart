import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

class Attachment {
  final XFile file;
  final bool isInternalScreenshot;
  String get path => file.path;
  String get name => file.name;
  String? get mimeType => file.mimeType;
  Future<Uint8List> readAsBytes() => file.readAsBytes();

  const Attachment({
    required this.file,
    required this.isInternalScreenshot,
  });

  factory Attachment.fromFile(XFile file) {
    return Attachment(
      file: file,
      isInternalScreenshot: false,
    );
  }

  factory Attachment.fromInternalScreenshot(String stringBase64) {
    final Uint8List uintList = base64Decode(stringBase64);
    return Attachment(
      file: XFile.fromData(
        uintList,
        mimeType: 'image/jpeg',
        length: uintList.length,
        name: 'screenshot-${uintList.length}.jpg',
      ),
      isInternalScreenshot: true,
    );
  }
  factory Attachment.fromInternalScreenshotBytes(Uint8List uintList) {
    return Attachment(
      file: XFile.fromData(
        uintList,
        mimeType: 'image/jpeg',
        length: uintList.length,
        name: 'screenshot-${uintList.length}.jpg',
      ),
      isInternalScreenshot: true,
    );
  }

  bool get isImage => mimeType?.contains('image') == true;
  bool get isText => mimeType?.contains('text') == true;
  bool get isWord => name.endsWith('.docx');
  bool get isExcel => name.endsWith('.xlsx') || name.endsWith('.xls');
  bool get isPdf => name.endsWith('.pdf');
}
