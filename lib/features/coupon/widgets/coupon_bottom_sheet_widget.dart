import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/widgets/custom_asset_image_widget.dart';
import '../../../features/coupon/domain/models/coupon_model.dart';
import '../../../helper/custom_snackbar_helper.dart';
import '../../../helper/date_converter_helper.dart';
import '../../../helper/price_converter_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../main.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../../utill/styles.dart';
import 'package:go_router/go_router.dart';

class CouponBottomSheetWidget extends StatelessWidget {
  final CouponModel? coupon;
  const CouponBottomSheetWidget({super.key, required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.paddingSizeDefault),
          topRight: Radius.circular(Dimensions.paddingSizeDefault),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ResponsiveHelper.isMobile())
              const SizedBox(height: Dimensions.paddingSizeDefault),

            /// Header section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: Dimensions.paddingSizeLarge),

                  if (ResponsiveHelper.isMobile())
                    Container(
                      transform: Matrix4.translationValues(12, 0, 0),
                      width: 35,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.3),
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
                      ),
                      transform: Matrix4.translationValues(0, -13, 0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
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
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(
                Dimensions.paddingSizeLarge,
              ).copyWith(top: Dimensions.paddingSizeExtraSmall),
              child: Row(
                children: [
                  const CustomAssetImageWidget(
                    Images.couponOfferIcon,
                    height: 35,
                    width: 35,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              coupon?.code ?? '',
                              style: poppinsBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),

                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: coupon?.code ?? ''),
                                ).then((value) {
                                  Future.delayed(
                                    const Duration(milliseconds: 800),
                                    () {
                                      showCustomSnackBarHelper(
                                        getTranslated(
                                          'coupon_code_copied',
                                          Get.context!,
                                        ),
                                        isError: false,
                                      );
                                    },
                                  );
                                });
                              },
                              child: CustomAssetImageWidget(
                                Images.copyIcon,
                                height: 14,
                                width: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),

                        Text(
                          '${PriceConverterHelper.percentageCalculation(context, coupon?.discount, coupon?.discountType)} ${coupon?.title}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
              ),
              child: Divider(
                height: 1,
                color: Theme.of(context).hintColor.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeExtraSmall,
                    ),
                    child: Text(
                      getTranslated('terms_and_condition', context),
                      style: poppinsBold,
                    ),
                  ),

                  _CouponItemWidget(
                    label: getTranslated('start_date', context),
                    info: DateConverterHelper.localDateToIsoStringAMPM(
                      DateConverterHelper.convertStringToDatetime(
                        coupon?.startDate ?? '',
                      ),
                      context,
                    ),
                  ),

                  _CouponItemWidget(
                    label: getTranslated('end_date', context),
                    info: DateConverterHelper.localDateToIsoStringAMPM(
                      DateConverterHelper.convertStringToDatetime(
                        coupon?.expireDate ?? '',
                      ),
                      context,
                    ),
                  ),

                  _CouponItemWidget(
                    label: getTranslated('limit_for_same_user', context),
                    info: '${coupon?.limit ?? 0}',
                  ),

                  _CouponItemWidget(
                    label: getTranslated('discount', context),
                    info: PriceConverterHelper.percentageCalculation(
                      context,
                      coupon?.discount,
                      coupon?.discountType,
                    ),
                  ),

                  _CouponItemWidget(
                    label: getTranslated('maximum_discount', context),
                    info: PriceConverterHelper.convertPrice(
                      context,
                      coupon?.maxDiscount,
                    ),
                  ),

                  _CouponItemWidget(
                    label: getTranslated('minimum_order_amount', context),
                    info: PriceConverterHelper.convertPrice(
                      context,
                      coupon?.minPurchase,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
        ),
      ),
    );
  }
}

class _CouponItemWidget extends StatelessWidget {
  final String? label;
  final String? info;
  const _CouponItemWidget({this.label, this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
            ),
            height: Dimensions.paddingSizeExtraSmall,
            width: Dimensions.paddingSizeExtraSmall,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),

          Text(
            '$label : $info',
            style: poppinsRegular.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
