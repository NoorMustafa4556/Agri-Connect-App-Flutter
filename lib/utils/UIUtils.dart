import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'AppColors.dart';

class UIUtils {
  static Widget shimmerPlaceholder({double? width, double? height, double borderRadius = 10}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static Widget darkShimmerPlaceholder({double? width, double? height, double borderRadius = 10}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static Widget getShimmer(BuildContext context, {double? width, double? height, double borderRadius = 10}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark 
        ? darkShimmerPlaceholder(width: width, height: height, borderRadius: borderRadius)
        : shimmerPlaceholder(width: width, height: height, borderRadius: borderRadius);
  }
}
