import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'MainController.dart';

class LeftBar extends StatelessWidget {
  LeftBar({Key? key}) : super(key: key);

  var controller = Get.put(MainController());
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Card(
        child: SizedBox(
          width: 200,
          child: Obx(
            () => ListView.builder(
              itemCount: controller.files.length,
              itemBuilder: (context, index) {
                var file = controller.files[index];
                var name = file.path.split("\\").last;
                return Obx(
                  () => GestureDetector(
                    onTap: () {
                      controller.setSelectedFile(file);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Card(
                        color: controller.selectedFile.value == file ? Colors.blue[200] : Colors.grey[200],
                        child: SizedBox(
                          height: 30,
                          child: Center(
                            child: Text(name),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
