import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'MainController.dart';

class TopBar extends StatelessWidget {
  TopBar({Key? key}) : super(key: key);

  var controller = Get.put(MainController());
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              const Text("数据目录:"),
              const SizedBox(width: 10),
              Obx(() => Text(controller.dir.value ?? "未选择")),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () async {
                    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                    if (selectedDirectory != null) {
                      controller.dir.value = selectedDirectory;
                    }
                  },
                  child: const Text("选择"))
            ]),
          ),
        ),
      ),
    );
  }
}
