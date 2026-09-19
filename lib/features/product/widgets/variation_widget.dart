import 'package:flutter/material.dart';
import '../../../common/models/product_model.dart';
import '../../../common/providers/cart_provider.dart';
import '../../../helper/responsive_helper.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class VariationWidget extends StatelessWidget {
  final Product? product;
  const VariationWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // Create a list of all variations with their attributes
        List<Map<String, dynamic>> allVariations = [];

        for (int i = 0; i < product!.choiceOptions!.length; i++) {
          for (int j = 0; j < product!.choiceOptions![i].options!.length; j++) {
            allVariations.add({
              'attributeIndex': i,
              'valueIndex': j,
              'attributeTitle': product!.choiceOptions![i].title,
              'attributeValue': product!.choiceOptions![i].options![j],
            });
          }
        }

        return Padding(
          padding: ResponsiveHelper.isDesktop(context)
              ? const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                  horizontal: Dimensions.paddingSizeLarge,
                )
              : const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : 2,
              crossAxisSpacing: Dimensions.paddingSizeDefault,
              mainAxisSpacing: Dimensions.paddingSizeDefault,
              childAspectRatio: ResponsiveHelper.isDesktop(context) ? 1.8 : 1.6,
            ),
            itemCount: allVariations.length,
            itemBuilder: (context, index) {
              final variation = allVariations[index];
              final int attributeIndex = variation['attributeIndex'];
              final int valueIndex = variation['valueIndex'];
              final bool isSelected =
                  cartProvider.variationIndex?[attributeIndex] == valueIndex;

              return InkWell(
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                onTap: () {
                  cartProvider.setCartVariationIndex(
                    attributeIndex,
                    valueIndex,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                        : Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusSizeTen,
                    ),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: isSelected ? 0.8 : 0.08),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Attribute Title
                      Padding(
                        padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeExtraSmall,
                          left: Dimensions.paddingSizeExtraSmall,
                          right: Dimensions.paddingSizeExtraSmall,
                        ),
                        child: Text(
                          variation['attributeTitle'],
                          style: poppinsMedium.copyWith(
                            fontSize: ResponsiveHelper.isDesktop(context)
                                ? Dimensions.fontSizeLarge
                                : Dimensions.fontSizeDefault,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Small Divider
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: 4,
                        ),
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.1),
                      ),

                      // Attribute Value
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeExtraSmall,
                          left: Dimensions.paddingSizeExtraSmall,
                          right: Dimensions.paddingSizeExtraSmall,
                        ),
                        child: Text(
                          variation['attributeValue'].trim(),
                          style: poppinsRegular.copyWith(
                            fontSize: ResponsiveHelper.isDesktop(context)
                                ? Dimensions.fontSizeDefault
                                : Dimensions.fontSizeSmall,
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.8)
                                : Theme.of(context).textTheme.bodyLarge?.color
                                      ?.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
