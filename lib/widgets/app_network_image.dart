import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network image cached on disk, so revisits load instantly and offline.
///
/// When [width] is known the image is decoded at display size rather than
/// full resolution, which keeps long lists light on memory. Pass
/// [fullResolution] for zoomable viewers.
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? error;
  final bool fullResolution;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.error,
    this.fullResolution = false,
  });

  @override
  Widget build(BuildContext context) {
    final w = width;
    final decodeWidth = !fullResolution && w != null && w.isFinite
        ? (w * MediaQuery.devicePixelRatioOf(context)).round()
        : null;

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: decodeWidth,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: placeholder == null ? null : (_, _) => placeholder!,
      errorWidget: (_, _, _) => error ?? const SizedBox.shrink(),
    );
  }
}
