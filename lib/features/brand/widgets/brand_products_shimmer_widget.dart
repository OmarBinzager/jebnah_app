import 'package:flutter/material.dart';
import '../../../utill/dimensions.dart';

class BrandProductsShimmerWidget extends StatelessWidget {
  const BrandProductsShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      itemCount: 8,
      itemBuilder: (context, index) {
        return ShimmerItem();
      },
      separatorBuilder: (ctx, idx) =>
          Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.1)),
    );
  }
}

class ShimmerItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // صورة متحركة
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          // نصوص متحركة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 8),
                Container(height: 10, width: 100, color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
