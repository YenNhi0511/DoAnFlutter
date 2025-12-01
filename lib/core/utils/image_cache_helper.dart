import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Helper for image caching and optimization
class ImageCacheHelper {
  /// Get cached network image with placeholder and error handling
  static Widget cachedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ??
          Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
      errorWidget: (context, url, error) => errorWidget ??
          Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          ),
      memCacheWidth: width != null ? width.toInt() : null,
      memCacheHeight: height != null ? height.toInt() : null,
    );
  }

  /// Clear image cache
  static Future<void> clearCache() async {
    await CachedNetworkImage.evictFromCache('');
  }
}

