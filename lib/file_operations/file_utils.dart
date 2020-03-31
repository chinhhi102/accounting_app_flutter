import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileUtils {
  static Future<String> get getFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }

  static Future<File> get getFile async {
    final path = await getFilePath;
    return File('$path/assets/images/');
  }

  static Future<File> saveToFile(File data) async {
    final file = await getFile;
    return file.writeAsString(data.toString());
  }

  static Future<String> readFromFile() async {
    try {
      final file = await getFile;
      String fileContents = await file.readAsString();
      return fileContents;
    } catch (e) {
      return "";
    }
  }
}