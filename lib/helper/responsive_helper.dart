import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../main.dart';

class ResponsiveHelper {
  static bool isMobilePhone() {
    if (!kIsWeb) {
      return true;
    } else {
      return false;
    }
  }

  static bool isWeb() {
    return kIsWeb;
  }

  /// Returns true for screens that should use mobile layout.
  /// On native platforms (iOS/Android), ALL devices — including iPad —
  /// use the mobile layout. On web, only screens narrower than 650px.
  static bool isMobile() {
    if (!kIsWeb) return true;
    final size = MediaQuery.of(Get.context!).size.width;
    return size < 650;
  }

  /// Returns true for tablet-sized screens (660–1299 px wide).
  /// Note: On native iOS/Android builds this always returns false because
  /// [isMobile] takes precedence. Use [isTab] only in web contexts.
  static bool isTab(BuildContext context) {
    if (!kIsWeb) return false;
    final size = MediaQuery.of(context).size.width;
    return size >= 660 && size < 1300;
  }

  /// Returns true only for wide desktop screens (≥ 1300 px).
  /// On native iOS/Android builds this always returns false.
  static bool isDesktop(BuildContext context) {
    if (!kIsWeb) return false;
    final size = MediaQuery.of(context).size.width;
    return size >= 1300;
  }

  Future<void> showDialogOrBottomSheet(
    BuildContext context,
    Widget view, {
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    if (ResponsiveHelper.isDesktop(context)) {
      await showDialog(
        barrierDismissible: isDismissible,
        context: context,
        builder: (ctx) => Center(child: view),
      );
    } else {
      await showModalBottomSheet(
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        backgroundColor: Colors.transparent,
        isScrollControlled: isScrollControlled,
        useSafeArea: true,
        context: context,
        builder: (ctx) => view,
      );
    }
  }
}
