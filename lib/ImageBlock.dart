import 'package:barmark/model/MarkPoint.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'MainController.dart';

class ImageBlock extends StatelessWidget {
  ImageBlock({Key? key}) : super(key: key);
  var controller = Get.put(MainController());
  RxList<MarkPoint> get points => controller.points;
  var imageWidth = Rx<double>(0);
  var imageHeight = Rx<double>(0);
  GlobalKey imageWidgetKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        child: GestureDetector(
          onPanDown: (details) {
            var size = imageWidgetKey.currentContext?.findRenderObject()?.paintBounds.size;
            if (size == null) return;
            var point = MarkPoint(
              name: controller.selectedPointType.value,
              x: details.localPosition.dx / imageWidth.value,
              y: details.localPosition.dy / imageHeight.value,
            );
            controller.addPoint(point);
            print("添加点:${point.x},${point.y}");
            controller.nextPointType();
          },
          child: Obx(() {
            if (controller.selectedFile.value == null) {
              return const Center(child: Text("请选择要标记的图片"));
            }
            return Stack(
              children: [
                LayoutBuilder(builder: ((context, constraints) {
                  var image = Image.file(controller.selectedFile.value!, fit: BoxFit.cover, key: imageWidgetKey);
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    var imageWidget = imageWidgetKey.currentWidget as Image;
                    Future.delayed(const Duration(milliseconds: 30), () {
                      imageWidth.value = context.size?.width ?? 1;
                      imageHeight.value = context.size?.height ?? 1;
                    });
                  });
                  return image;
                })),
                ...points.map((point) {
                  return Positioned(
                    left: (point.x * imageWidth.value) - 5,
                    top: (point.y * imageHeight.value) - 5,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: pointTypes[point.name],
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                            color: Colors.white, width: point.name == controller.selectedPointType() ? 3 : 1),
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Card(
  //     child: SizedBox(
  //       child: Obx(() {
  //         if (controller.selectedFile.value != null) {
  //           var stacChildren = <Widget>[];
  //           var image = Image.file(controller.selectedFile.value!, fit: BoxFit.cover, key: imageWidgetKey);
  //           image.image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _) {
  //             print("宽:${info.image.width} 高:${info.image.height}");
  //             imageWidth.value = info.image.width;
  //             imageHeight.value = info.image.height;
  //           }));
  //           stacChildren.add(
  //             image,
  //           );

  //           var size = imageWidgetKey.currentContext?.findRenderObject()?.paintBounds.size;
  //           if (size != null) {
  //             for (var point in points) {
  //               stacChildren.add(
  //                 Positioned(
  //                   left: (point.x * size.width) - 5,
  //                   top: (point.y * size.height) - 5,
  //                   child: Container(
  //                     width: 10,
  //                     height: 10,
  //                     decoration: BoxDecoration(
  //                       color: pointTypes[point.name],
  //                       borderRadius: const BorderRadius.all(Radius.circular(10)),
  //                       border: Border.all(
  //                           color: Colors.white, width: point.name == controller.selectedPointType() ? 3 : 1),
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             }
  //           }

  //           stacChildren.add(
  //             Positioned(
  //               top: 0,
  //               left: 0,
  //               child: Text("照片真实尺寸:${imageWidth.value}x${imageHeight.value}"),
  //             ),
  //           );
  //           return Center(
  //             child: GestureDetector(
  //               onPanDown: (details) {
  //                 var size = imageWidgetKey.currentContext?.findRenderObject()?.paintBounds.size;
  //                 if (size == null) return;
  //                 var point = MarkPoint(
  //                   name: controller.selectedPointType.value,
  //                   x: details.localPosition.dx / size.width,
  //                   y: details.localPosition.dy / size.height,
  //                 );
  //                 controller.addPoint(point);
  //                 print("添加点:${point.x},${point.y}");
  //                 controller.nextPointType();
  //               },
  //               child: Stack(children: stacChildren),
  //             ),
  //           );
  //         }
  //         return const Center(child: Text("请选择要标记的图片"));
  //       }),
  //     ),
  //   );
  // }
}
