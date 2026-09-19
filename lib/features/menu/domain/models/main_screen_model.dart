import 'package:flutter/material.dart';

class MainScreenModel{
  final Widget screen;
  final String title;
  final String icon;
  final bool isActive;
  MainScreenModel(this.screen, this.title, this.icon, this.isActive);
}