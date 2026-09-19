import 'package:flutter/material.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/styles.dart';

class BrandItemWidget extends StatelessWidget {
  final String? title;
  final String? icon;
  final bool isSelected;

  const BrandItemWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
        horizontal: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
        border: isSelected
            ? Border.all(color: Theme.of(context).primaryColor, width: 1)
            : null,
      ),
      child: Column(
        children: [
          // صورة العلامة التجارية
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            child: icon != null && icon!.isNotEmpty
                ? Image.network(
                    icon!,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain, // تغيير إلى contain كما طلبت
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 50,
                        width: 50,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.business,
                          size: 30,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  )
                : Container(
                    height: 50,
                    width: 50,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.business,
                      size: 30,
                      color: Colors.grey.shade400,
                    ),
                  ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          // اسم العلامة التجارية
          Text(
            title ?? '',
            style: poppinsRegular.copyWith(
              fontSize: 11,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
