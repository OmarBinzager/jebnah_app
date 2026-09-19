import 'package:flutter/material.dart';
import '../../../common/providers/product_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class RatingLineWidget extends StatelessWidget {
  const RatingLineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        int fiveStar = 0;
        int fourStar = 0;
        int threeStar = 0;
        int twoStar = 0;
        int oneStar = 0;

        for (var review in productProvider.product!.activeReviews!) {
          if (review.rating! >= 4.5) {
            fiveStar++;
          } else if (review.rating! >= 3.5 && review.rating! < 4.5) {
            fourStar++;
          } else if (review.rating! >= 2.5 && review.rating! < 3.5) {
            threeStar++;
          } else if (review.rating! >= 1.5 && review.rating! < 12.5) {
            twoStar++;
          } else {
            oneStar++;
          }
        }

        int totalReview =
            (fiveStar + fourStar + threeStar + twoStar + oneStar) == 0
            ? 1
            : (fiveStar + fourStar + threeStar + twoStar + oneStar);

        double five = (fiveStar / totalReview);
        double four = (fourStar / totalReview);
        double three = (threeStar / totalReview);
        double two = (twoStar / totalReview);
        double one = (oneStar / totalReview);

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '5',
                    style: poppinsRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(flex: 10, child: LinearProgressIndicator(value: five)),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  flex: 2,
                  child: Text(
                    '${(five * 100).toInt()}%',
                    style: poppinsRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '4',
                    style: poppinsRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(flex: 10, child: LinearProgressIndicator(value: four)),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  flex: 2,
                  child: Text(
                    '${(four * 100).toInt()}%',
                    style: poppinsRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '3',
                    style: poppinsRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  flex: 10,
                  child: LinearProgressIndicator(value: three),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  flex: 2,
                  child: Text(
                    '${(three * 100).toInt()}%',
                    style: poppinsRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '2',
                    style: poppinsRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(flex: 10, child: LinearProgressIndicator(value: two)),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  flex: 2,
                  child: Text(
                    '${(two * 100).toInt()}%',
                    style: poppinsRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '1',
                    style: poppinsRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(flex: 10, child: LinearProgressIndicator(value: one)),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  flex: 2,
                  child: Text(
                    '${(one * 100).toInt()}%',
                    style: poppinsRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
