import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAssetImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Color? color;
  final BlendMode? colorBlendMode;
  final int? cacheWidth;
  final int? cacheHeight;

  const CustomAssetImageWidget(
    this.image, {
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.color,
    this.colorBlendMode,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isSvg = image.contains('.svg', image.length - '.svg'.length);

    if (isSvg) {
      return SvgPicture.asset(
        image,
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        fit: fit,
      );
    }

    return Image.asset(
      image,
      fit: fit,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      gaplessPlayback: true,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return SizedBox(width: width, height: height);
      },
      errorBuilder: (context, error, stackTrace) =>
          SizedBox(width: width, height: height),
    );
  }
}
