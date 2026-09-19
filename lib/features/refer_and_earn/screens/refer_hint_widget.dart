import 'package:flutter/material.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import 'package:go_router/go_router.dart';

class ReferHintWidget extends StatelessWidget {
  final List<String?>? hintList;
  const ReferHintWidget({super.key, this.hintList});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ResponsiveHelper.isMobile())
                  const SizedBox(width: Dimensions.paddingSizeLarge),

                if (ResponsiveHelper.isMobile()) ...[
                  Container(
                    transform: Matrix4.translationValues(12, 0, 0),
                    width: 35,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSizeDefault,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                  ),

                  InkWell(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeSmall,
                      ).copyWith(bottom: 0),
                      transform: Matrix4.translationValues(0, -10, 0),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: Dimensions.fontSizeExtraLarge,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.all(
              Dimensions.paddingSizeDefault,
            ).copyWith(top: 0),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Image.asset(
                      Images.iMark,
                      height: Dimensions.fontSizeDefault,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Text(
                      getTranslated('how_it_works', context),
                      style: poppinsBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Column(
                  children: hintList!
                      .map(
                        (hint) => Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${hintList!.indexOf(hint) + 1}.',
                                style: poppinsRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeDefault,
                            ),

                            Flexible(
                              child: Text(
                                hint!,
                                style: poppinsRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
