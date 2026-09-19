import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../common/widgets/custom_toast.dart';
import '../helper/responsive_helper.dart';
import '../localization/language_constraints.dart';
import '../main.dart';
import '../utill/dimensions.dart';
import '../utill/styles.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum SnackBarStatus { error, success, alert, info }

enum SnackBarWebPosition { topLeft, topRight, bottomLeft, bottomRight, center }

void showCustomSnackBarHelper(
  String? message, {
  bool isError = true,
  bool isToast = false,
  SnackBarStatus? snackBarStatus,
  SnackBarWebPosition? snackBarWebPosition = SnackBarWebPosition.topRight,
}) {
  final Size size = MediaQuery.of(Get.context!).size;

  if (ResponsiveHelper.isDesktop(Get.context!)) {
    CustomToast().show(
      message ?? '',
      isError: isError,
      snackBarStatus: snackBarStatus,
      navigatorKey: navigatorKey,
      borderRadius: 100,
      duration: const Duration(seconds: 1),
    );
  } else {
    ScaffoldMessenger.of(Get.context!)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          elevation: 0,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          content: Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.black.withValues(alpha: 0.7),
              elevation: 0,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                constraints: const BoxConstraints(minHeight: 50),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    snackBarStatus != null &&
                            snackBarStatus == SnackBarStatus.info
                        ? const Icon(
                            Icons.warning_rounded,
                            color: Colors.orangeAccent,
                            size: 22, // Icon size
                          )
                        : CircleAvatar(
                            radius: 12, // Adjust radius as needed
                            backgroundColor: isError
                                ? Colors.red
                                : Colors
                                      .green, // Background color of the circle
                            child: Icon(
                              isError ? Icons.close_rounded : Icons.check,
                              color: Colors.white,
                              size: 16, // Icon size
                            ),
                          ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Flexible(
                      child: Text(
                        message ?? '',
                        style: poppinsRegular.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          margin: snackBarMargin(snackBarWebPosition, size),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
        ),
      );
  }
}

EdgeInsets? snackBarMargin(
  SnackBarWebPosition? snackBarWebPosition,
  Size size,
) {
  if (!ResponsiveHelper.isDesktop(Get.context!))
    return EdgeInsets.only(bottom: size.height * 0.1);

  switch (snackBarWebPosition) {
    case SnackBarWebPosition.bottomLeft:
      return EdgeInsets.only(
        right: size.width * 0.7,
        bottom: Dimensions.paddingSizeExtraSmall,
        left: Dimensions.paddingSizeExtraSmall,
      );

    case SnackBarWebPosition.bottomRight:
      return EdgeInsets.only(
        bottom: Dimensions.paddingSizeExtraSmall,
        right: Dimensions.paddingSizeExtraSmall,
        left: size.width * 0.7,
      );

    case SnackBarWebPosition.topRight:
      return EdgeInsets.only(
        bottom: size.height * 0.7,
        right: Dimensions.paddingSizeExtraSmall,
        left: size.width * 0.7,
      );

    case SnackBarWebPosition.topLeft:
      return EdgeInsets.only(
        bottom: size.height * 0.7,
        right: size.width * 0.7,
        left: Dimensions.paddingSizeExtraSmall,
      );

    default:
      return null;
  }
}

void showFlutterDefaultToaster({
  required String message,
  bool isError = true,
  Color? backgroundColor,
}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    backgroundColor: backgroundColor ?? (isError ? Colors.red : Colors.green),
  );
}

enum ToasterMessageType { success, error, info }

void showFlutterCustomToaster(
  String? message, {
  ToasterMessageType type = ToasterMessageType.error,
  double margin = Dimensions.paddingSizeSmall,
  int duration = 2,
  Color? backgroundColor,
  Widget? customWidget,
  double borderRadius = Dimensions.radiusSizeSmall,
  bool showDefaultSnackBar = true,
  String? icon,
  String? toasterTitle,
  required BuildContext context,
}) {
  FToast fToast = FToast();
  fToast.init(context);
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    margin: EdgeInsets.only(bottom: 50),
    decoration: BoxDecoration(
      color: const Color(0xFF393f47),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon != null
            ? Image.asset(icon, width: 25)
            : Icon(
                type == ToasterMessageType.error
                    ? CupertinoIcons.multiply_circle_fill
                    : type == ToasterMessageType.info
                    ? Icons.info
                    : Icons.check_circle,
                color: type == ToasterMessageType.info
                    ? Colors.blueAccent
                    : type == ToasterMessageType.error
                    ? const Color(0xffFF9090).withValues(alpha: 0.5)
                    : const Color(0xff039D55),
                size: 20,
              ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (toasterTitle != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    getTranslated(toasterTitle, context),
                    style: poppinsMedium.copyWith(color: Colors.white),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Text(
                getTranslated(message ?? "", context),
                style: poppinsRegular.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: toasterTitle != null ? 1.0 : 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ResponsiveHelper.isDesktop(context)
        ? ToastGravity.TOP_RIGHT
        : ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: duration),
  );
}
