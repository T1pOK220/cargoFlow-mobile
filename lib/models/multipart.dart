import 'package:image_picker/image_picker.dart';
abstract class MultipartModel {
  Map<String, dynamic> toJson();

  XFile? get file;
}