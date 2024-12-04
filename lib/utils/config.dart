import 'package:flutter/material.dart';

class Config {
  static const app_logo = 'assets/logo.png';
  static const app_logo2 = 'assets/logo2.png';
  static const app_person = 'assets/person.png';


}

List<BoxShadow> shadowList = [
  const BoxShadow(color: Colors.grey, blurRadius: 30, offset: Offset(0, 10))
];
List<BoxShadow> shadowListDown = [
  const BoxShadow(
    color: Colors.grey,
    blurRadius: 30,
    offset: Offset(0, 1),
  ),
];
