import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../common/widgets/custom_asset_image_widget.dart';
import '../../../../utill/images.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit fit;
  final bool isNotification;
  final String placeholder;

  const CustomImageWidget({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.isNotification = false,
    this.placeholder = '',
  });

  @override
  Widget build(BuildContext context) {
    final placeholderImage = placeholder.isNotEmpty
        ? placeholder
        : Images.placeHolder;

    if (image.isEmpty) {
      return CustomAssetImageWidget(
        placeholderImage,
        height: height,
        width: width,
        fit: fit,
      );
    }

    if (kIsWeb) {
      return Container(
        height: height,
        width: width,
        color: Theme.of(context).cardColor,
        child: Image.network(
          image,
          height: height,
          width: width,
          fit: fit,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return child;
            }
            return Container(
              color: Theme.of(context).cardColor,
              child: CustomAssetImageWidget(
                placeholderImage,
                height: height,
                width: width,
                fit: fit,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Theme.of(context).cardColor,
            child: CustomAssetImageWidget(
              placeholderImage,
              height: height,
              width: width,
              fit: fit,
            ),
          ),
        ),
      );
    }

    return Container(
      height: height,
      width: width,
      color: Theme.of(context).cardColor,
      child: CachedNetworkImage(
        imageUrl: image,
        height: height,
        width: width,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
        useOldImageOnUrlChange: true,
        placeholder: (context, url) => Container(
          color: Theme.of(context).cardColor,
          child: Center(
            child: Transform.scale(
              scale: 1.8,
              alignment: Alignment.center,
              child: Lottie.asset(
                'assets/lottie/jebnah_logo_animation.json',
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
                errorBuilder: (context, error, stackTrace) =>
                    CustomAssetImageWidget(
                      placeholderImage,
                      height: height,
                      width: width,
                      fit: fit,
                    ),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Theme.of(context).cardColor,
          child: CustomAssetImageWidget(
            placeholderImage,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      ),
    );
  }
}
