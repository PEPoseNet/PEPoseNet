import 'dart:io';

bool isImageFile(File file) {
  var a = file.path.split(".").last.toLowerCase();
  return a == "jpg" || a == "png" || a == "jpeg";
}
