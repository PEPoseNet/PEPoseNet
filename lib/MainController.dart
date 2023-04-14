import 'dart:convert';
import 'dart:io';

import 'package:barmark/utils/FileUtil.dart';
import 'package:get/get.dart';

import 'model/MarkPoint.dart';

class MainController extends GetxController {
  var dir = Rx<String?>(null);

  var files = RxList<File>([]);

  var selectedFile = Rx<File?>(null);
  var points = RxList<MarkPoint>();
  var selectedPointType = Rx<String>("nose");

  @override
  void onInit() {
    super.onInit();
    dir.listen((path) {
      if (path == null) return;
      var d = Directory(path);
      files.clear();
      d.listSync().forEach((f) {
        if (f is File && isImageFile(f)) {
          files.add(f);
        }
      });
      files.sort((a, b) => a.path.compareTo(b.path));
    });

    selectedFile.listen((file) {
      points.clear();
      if (file == null) return;
      readPointsFromFile(file.path);
      selectedPointType.value = "right_bar";
    });
  }

  setSelectedFile(File file) async {
    if (selectedFile.value != file) {
      await savePoints();
    }
    selectedFile.value = file;
  }

  nextFile() {
    var index = files.indexOf(selectedFile.value);
    if (index == files.length - 1) {
      index = 0;
    } else {
      index++;
    }
    setSelectedFile(files[index]);
  }

  addPoint(MarkPoint point) {
    points.removeWhere((element) => element.name == point.name);
    points.add(point);
  }

  MarkPoint? getPoint(String type) {
    return points.firstWhereOrNull((element) => element.name == type);
  }

  void nextPointType() {
    var index = pointTypes.keys.toList().indexOf(selectedPointType.value);
    if (index != pointTypes.keys.length - 1) {
      selectedPointType.value = pointTypes.keys.toList()[index + 1];
    }
  }

  void readPointsFromFile(String imagePath) async {
    var jsonFileName = "$imagePath.json";
    var jsonFile = File(jsonFileName);
    if (!jsonFile.existsSync()) {
      return;
    }
    var json = await jsonFile.readAsString();
    var data = jsonDecode(json) as Map<String, dynamic>;
    for (var type in pointTypes.keys) {
      var p = data[type] as Map<String, dynamic>?;
      if (p == null) continue;
      var point = MarkPoint(
        name: type,
        x: p["x"],
        y: p["y"],
      );
      points.add(point);
    }
  }

  savePoints() async {
    if (selectedFile.value == null) return;
    var jsonFileName = "${selectedFile.value!.path}.json";
    var jsonFile = File(jsonFileName);
    if (!jsonFile.existsSync()) {
      await jsonFile.create();
    }
    var json = "{${points.map((p) => p.toJson()).join(",")}}";
    await jsonFile.writeAsString(json.toString());
  }
}
