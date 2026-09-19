import 'package:flutter/material.dart';
import '../../../features/checkout/domain/models/check_out_model.dart';
import '../../../common/models/config_model.dart';
import '../../../features/checkout/widgets/image_note_upload_widget.dart';
import '../../../localization/language_constraints.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';
import '../../../common/widgets/custom_shadow_widget.dart';
import '../../../common/widgets/custom_text_field_widget.dart';
import '../../../features/checkout/widgets/payment_section_widget.dart';
import 'package:provider/provider.dart';

class DetailsWidget extends StatelessWidget {
  const DetailsWidget({
    super.key,
    required this.paymentList,
    required this.noteController,
    required this.weightCharge,
  });

  final List<PaymentMethod> paymentList;
  final TextEditingController noteController;
  final double weightCharge;

  @override
  Widget build(BuildContext context) {
    CheckOutModel? checkOutData = Provider.of<OrderProvider>(
      context,
      listen: false,
    ).getCheckOutData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaymentSectionWidget(
          total:
              (checkOutData?.amount ?? 0) +
              (checkOutData?.deliveryCharge ?? 0) +
              weightCharge,
        ),

        //PartialPayWidget(totalPrice: (checkOutData?.amount ?? 0) + (checkOutData?.deliveryCharge ?? 0)),
        const ImageNoteUploadWidget(),

        CustomShadowWidget(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated('add_delivery_note', context),
                style: poppinsRegular,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextFieldWidget(
                fillColor: Theme.of(context).canvasColor,
                isShowBorder: true,
                controller: noteController,
                hintText: getTranslated('type', context),
                maxLines: 3,
                inputType: TextInputType.multiline,
                inputAction: TextInputAction.newline,
                capitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
