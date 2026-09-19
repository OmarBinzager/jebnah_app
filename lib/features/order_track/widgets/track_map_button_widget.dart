import 'package:flutter/material.dart';
import '../../../common/widgets/custom_button_widget.dart';
import '../../../features/order/providers/order_provider.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../localization/language_constraints.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';

class TrackMapButtonWidget extends StatelessWidget {
  final OrderProvider orderProvider;
  const TrackMapButtonWidget({super.key, required this.orderProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: ResponsiveHelper.isDesktop(context)
          ? Dimensions.webScreenWidth * 0.4
          : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        image: const DecorationImage(
          image: AssetImage(Images.mapBg), // Load from assets
          fit: BoxFit.cover, // Adjust how the image fits
        ),
      ),
      margin: const EdgeInsets.only(top: 10),
      child: Center(
        child: SizedBox(
          width: 170,
          height: 40,
          child: CustomButtonWidget(
            buttonText: getTranslated("view_on_map", context),
            onPressed: () {
              RouteHelper.getTrackMapScreen(
                order: orderProvider.trackModel,
                deliverymanId: orderProvider.trackModel?.deliveryManId,
                orderId: orderProvider.trackModel?.id,
              );
            },
          ),
        ),
      ),
    );
  }
}
