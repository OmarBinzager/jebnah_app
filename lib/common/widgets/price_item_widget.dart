import 'package:flutter/material.dart';
import '../../../../common/widgets/custom_directionality_widget.dart';
import '../../../../utill/dimensions.dart';
import '../../../../utill/styles.dart';

class PriceItemWidget extends StatelessWidget {
  const PriceItemWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.style,
  });

  final String title;
  final String subTitle;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
              style ??
              poppinsRegular.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              ),
        ),

        CustomDirectionalityWidget(
          child: Text(
            subTitle,
            style:
                style ??
                poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
        ),
      ],
    );
  }
}
