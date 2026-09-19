import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoaderWidget extends StatelessWidget {
  const CustomLoaderWidget({
    super.key,
    this.color,
    this.size = 180.0,
    this.itemBuilder,
    this.duration,
    this.controller,
  });

  final Color? color;
  final double size;
  final IndexedWidgetBuilder? itemBuilder;
  final Duration? duration;
  final AnimationController? controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Transform.scale(
          scale: 1.8,
          child: Lottie.asset(
            'assets/lottie/jebnah_logo_animation.json',
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
            errorBuilder: (context, error, stackTrace) {
              return Lottie.asset(
                'assets/lottie/jebnah_logo_animation.lottie',
                decoder: LottieComposition.decodeZip,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
                errorBuilder: (context, err, st) {
                  return SizedBox.fromSize(
                    size: Size.square(size),
                    child: Center(
                      child: SizedBox(
                        width: size * 0.6,
                        height: size * 0.6,
                        child: CircularProgressIndicator(
                          valueColor: color != null
                              ? AlwaysStoppedAnimation<Color>(color!)
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
