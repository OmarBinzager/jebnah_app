import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/models/product_model.dart';
import '../../../../common/providers/product_provider.dart';
import '../../../../helper/route_helper.dart';
import '../../../../utill/dimensions.dart';
import '../../../../utill/styles.dart';
import 'product_widget.dart';

class RelatedProductsWidget extends StatefulWidget {
  final String productId;

  const RelatedProductsWidget({super.key, required this.productId});

  @override
  State<RelatedProductsWidget> createState() => _RelatedProductsWidgetState();
}

class _RelatedProductsWidgetState extends State<RelatedProductsWidget> {
  bool _isLoading = true;
  List<Product>? _products;

  @override
  void initState() {
    super.initState();
    // تحميل البيانات بعد البناء مباشرة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRelatedProducts();
    });
  }

  Future<void> _loadRelatedProducts() async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    try {
      // استدعاء الدالة التي تعدلناها سابقاً
      await productProvider.getRelatedProductsSimple(widget.productId);

      if (mounted) {
        setState(() {
          _products = productProvider.relatedProductsList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _products = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_products == null || _products!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Text(
            'منتجات ذات صلة',
            style: poppinsSemiBold.copyWith(fontSize: 18),
          ),
        ),

        // قائمة المنتجات المتعلقة (سكرول أفقي)
        SizedBox(
          height: 330,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            itemCount: _products!.length,
            itemBuilder: (context, index) {
              final product = _products![index];

              return Container(
                width: 180,
                margin: const EdgeInsets.only(
                  right: Dimensions.paddingSizeSmall,
                ),
                child: ProductWidget(
                  product: product,
                  productType: 'related',
                  isGrid: true,
                  isCenter: false,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: Dimensions.paddingSizeDefault),
      ],
    );
  }
}
