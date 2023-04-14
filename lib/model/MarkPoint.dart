import 'package:flutter/material.dart';

class MarkPoint {
  String name;
  double x;
  double y;
  MarkPoint({required this.name, required this.x, required this.y});

  String toJson() {
    return '"$name":{"x":$x,"y":$y}';
  }
}

var pointTypes = {
  'nose': Colors.blue,
  'right_shoulder': Colors.red,
  'left_shoulder': Colors.green,
  'right_elbow': Colors.orange,
  'left_elbow': Colors.purple,
  'right_wrist': Colors.cyan[700],
  'left_wrist': Colors.pink,
  'right_hip': Colors.cyan,
  'left_hip': Colors.teal,
  'right_knee': Colors.lime,
  'left_knee': Colors.indigo,
  'right_ankle': Colors.lightBlue,
  'left_ankle': Colors.lightGreen,
  'right_bar': Colors.indigoAccent,
  'left_bar': Colors.orangeAccent,
};
