import 'package:flutter/material.dart';
import '../../../../features/menu/domain/enums/drawer_state_enun.dart';

class CustomDrawerController {
  Function? open;
  Function? close;
  late Function toggle;
  late Function isOpen;
  ValueNotifier<DrawerState>? stateNotifier;
}
