import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/widgets/custom_asset_image_widget.dart';
import '../../../common/widgets/custom_button_widget.dart';
import '../../../features/coupon/domain/models/coupon_model.dart';
import '../../../features/coupon/providers/coupon_provider.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../../../helper/date_converter_helper.dart';
import '../../../helper/price_converter_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import 'package:provider/provider.dart';

class CouponCardWidget extends StatelessWidget {
  final CouponModel? coupon;
  final bool fromCart;
  final Function()? onApplyTap;
  final bool isAvailable;

  const CouponCardWidget({
    super.key,
    this.coupon,
    this.fromCart = false,
    this.onApplyTap,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double widthSize = constraints.maxWidth;

        return Consumer<CouponProvider>(
          builder: (context, couponProvider, _) {
            final bool isApplied =
                couponProvider.coupon?.id != null &&
                couponProvider.coupon?.id == coupon?.id;

            return Container(
              constraints: const BoxConstraints(maxHeight: 120),
              width: widthSize,
              padding: const EdgeInsets.only(
                bottom: Dimensions.paddingSizeDefault,
              ),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(Dimensions.paddingSizeExtraSmall),
                      ),
                      border: Border.all(
                        width: 1,
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).secondaryHeaderColor.withValues(alpha: 0.1),
                          offset: const Offset(0, 5),
                          blurRadius: 10,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                            right: Dimensions.paddingSizeExtraSmall,
                          ),
                          width: widthSize * 0.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CustomAssetImageWidget(
                                Images.couponOfferIcon,
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),

                              Text(
                                PriceConverterHelper.percentageCalculation(
                                  context,
                                  coupon?.discount,
                                  coupon?.discountType,
                                ),
                                style: poppinsBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),

                              Text(
                                coupon?.title ?? '',
                                style: poppinsRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        DottedLine(
                          direction: Axis.vertical,
                          dashColor: Theme.of(
                            context,
                          ).hintColor.withValues(alpha: 0.4),
                          lineThickness: 1,
                          dashLength: 5,
                        ),

                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              fromCart
                                  ? isAvailable
                                        ? Container(
                                            padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeExtraSmall,
                                            ),
                                            width: 85,
                                            height: 35,
                                            child: CustomButtonWidget(
                                              buttonText: getTranslated(
                                                isApplied ? 'applied' : 'apply',
                                                context,
                                              ),
                                              borderRadius: 100,
                                              borderColor: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.5),
                                              backgroundColor: Theme.of(
                                                context,
                                              ).cardColor,
                                              textStyle: poppinsMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: isApplied
                                                    ? Theme.of(
                                                        context,
                                                      ).cardColor
                                                    : Theme.of(
                                                        context,
                                                      ).primaryColor,
                                              ),
                                              onPressed: isApplied
                                                  ? null
                                                  : onApplyTap,
                                            ),
                                          )
                                        : const SizedBox()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            coupon?.code ?? '',
                                            style: poppinsBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall,
                                        ),

                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text: coupon?.code ?? '',
                                              ),
                                            ).then((value) {
                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 800,
                                                ),
                                                () {
                                                  showCustomSnackBarHelper(
                                                    getTranslated(
                                                      'coupon_code_copied',
                                                      context,
                                                    ),
                                                    isError: false,
                                                  );
                                                },
                                              );
                                            });
                                          },
                                          child: const CustomAssetImageWidget(
                                            Images.copyIcon,
                                            height:
                                                Dimensions.paddingSizeDefault,
                                            width:
                                                Dimensions.paddingSizeDefault,
                                          ),
                                        ),
                                      ],
                                    ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),

                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          DateConverterHelper.isoStringToLocalDateOnly(
                                            coupon?.startDate ?? '',
                                          ),
                                    ),

                                    TextSpan(
                                      text: ' ${getTranslated('to', context)} ',
                                    ),

                                    TextSpan(
                                      text:
                                          DateConverterHelper.isoStringToLocalDateOnly(
                                            coupon?.expireDate ?? '',
                                          ),
                                    ),
                                  ],
                                ),
                                style: poppinsRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                              const SizedBox(height: 2),

                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '*',
                                      style: poppinsRegular.copyWith(
                                        color: Colors.red,
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),

                                    TextSpan(
                                      text:
                                          '${getTranslated('min_purchase', context)} ',
                                    ),

                                    TextSpan(
                                      text: PriceConverterHelper.convertPrice(
                                        context,
                                        coupon?.minPurchase,
                                      ),
                                    ),
                                  ],
                                ),
                                style: poppinsRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(Dimensions.paddingSizeExtraSmall),
                          ),
                          color: Theme.of(
                            context,
                          ).hintColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ),

                  Positioned(
                    bottom: -22,
                    left: widthSize * 0.3,
                    child: Container(
                      width: 22,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          width: 1,
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: -22,
                    left: widthSize * 0.3,
                    child: Container(
                      width: 22,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          width: 1,
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
