import 'package:barmark/model/MarkPoint.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'MainController.dart';

class RightBar extends StatelessWidget {
  RightBar({Key? key}) : super(key: key);

  var controller = Get.put(MainController());
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Card(
        child: SizedBox(
          width: 250,
          height: double.infinity,
          child: Column(children: [
            ...pointTypes.keys.map(
              (n) {
                return Obx(() {
                  var color = pointTypes[n];
                  var point = controller.getPoint(n);
                  return GestureDetector(
                    onTap: () => controller.selectedPointType.value = n,
                    child: Card(
                      child: SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (controller.selectedPointType.value == n)
                              Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            Text(
                              n +
                                  (point != null
                                      ? "(${point.x.toStringAsFixed(2)},${point.y.toStringAsFixed(2)})"
                                      : ""),
                              style: TextStyle(
                                color: color,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              },
            ).toList(),
            ElevatedButton(
              onPressed: () {
                controller.savePoints();
              },
              child: const Text("保存"),
            )
          ]),
        ),
      ),
    );
  }
}
