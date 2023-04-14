import 'package:barmark/ImageBlock.dart';
import 'package:barmark/RightBar.dart';
import 'package:barmark/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'LeftBar.dart';
import 'MainController.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  var controller = Get.put(MainController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 1280,
        height: 720,
        child: Column(children: [
          TopBar(),
          Expanded(
            child: Row(
              children: [
                LeftBar(),
                Expanded(child: ImageBlock()),
                RightBar(),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
