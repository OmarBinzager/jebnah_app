import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../features/home/domain/models/banner_model.dart';
import 'route_helper.dart';

class BannerTapHelper {
  static Future<void> onBannerTap(BuildContext context, BannerModel banner) async {
    // 1. External link
    if (banner.clickAction == 'link' ||
        (banner.externalLink != null && banner.externalLink!.trim().isNotEmpty)) {
      final link = banner.externalLink?.trim();
      if (link != null && link.isNotEmpty) {
        final uri = Uri.tryParse(link.startsWith('http') ? link : 'https://$link');
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      }
    }

    // 2. Product navigation
    if (banner.clickAction == 'product' || banner.productId != null) {
      if (banner.productId != null) {
        RouteHelper.getProductDetailsRoute(productId: banner.productId);
        return;
      }
    }

    // 3. Category navigation
    if (banner.clickAction == 'category' || banner.categoryId != null) {
      if (banner.categoryId != null) {
        RouteHelper.getCategoryProductsRoute(categoryId: '${banner.categoryId}');
        return;
      }
    }

    // 4. Fallback checks for multi item IDs if assigned
    if (banner.productIdsAsInt != null && banner.productIdsAsInt!.isNotEmpty) {
      RouteHelper.getProductDetailsRoute(productId: banner.productIdsAsInt!.first);
      return;
    }
    if (banner.categoryIdsAsInt != null && banner.categoryIdsAsInt!.isNotEmpty) {
      RouteHelper.getCategoryProductsRoute(categoryId: '${banner.categoryIdsAsInt!.first}');
      return;
    }
  }
}
