import 'package:flutter/material.dart';
import 'package:saluun_frontend/core/theme/app_design_system.dart';

/// Widget to display ratings as stars
/// Shows filled, half, and empty stars based on the rating value
class RatingStars extends StatelessWidget {
  final double? rating;
  final int? reviewCount;
  final double size;
  final MainAxisAlignment mainAxisAlignment;
  final bool showReviewCount;
  final TextStyle? ratingTextStyle;
  final TextStyle? reviewCountTextStyle;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 16,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.showReviewCount = true,
    this.ratingTextStyle,
    this.reviewCountTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final displayRating = rating ?? 0.0;

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        // Stars
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return _buildStar(context, index, displayRating);
          }),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Rating text and review count
        if (rating != null || reviewCount != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating value
              Text(
                displayRating.toStringAsFixed(1),
                style:
                    ratingTextStyle ??
                    Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),

              // Review count
              if (showReviewCount && reviewCount != null)
                Text(
                  '${reviewCount ?? 0} reviews',
                  style:
                      reviewCountTextStyle ??
                      Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
                ),
            ],
          ),
      ],
    );
  }

  /// Build individual star widget
  Widget _buildStar(BuildContext context, int index, double rating) {
    final isFullStar = index < rating.floor();
    final isHalfStar = !isFullStar && (index < rating.ceil());
    final fillPercentage = isFullStar ? 1.0 : (isHalfStar ? 0.5 : 0.0);

    return Stack(
      children: [
        // Empty star background
        Icon(Icons.star_rate, size: size, color: AppColors.grey300),

        // Filled star overlay
        ClipRect(
          clipper: _StarClipper(fillPercentage),
          child: Icon(Icons.star_rate, size: size, color: AppColors.warning),
        ),
      ],
    );
  }
}

/// Custom clipper for partial star fill
class _StarClipper extends CustomClipper<Rect> {
  final double fillPercentage;

  _StarClipper(this.fillPercentage);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fillPercentage, size.height);
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) {
    return oldClipper.fillPercentage != fillPercentage;
  }
}

/// Compact rating display variant (fewer details)
class RatingStarsCompact extends StatelessWidget {
  final double? rating;
  final double size;

  const RatingStarsCompact({super.key, required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final displayRating = rating ?? 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < displayRating.floor();
        final isHalf = !isFilled && index < displayRating.ceil();

        return Stack(
          children: [
            Icon(Icons.star_rate, size: size, color: AppColors.grey300),
            if (isFilled || isHalf)
              ClipRect(
                clipper: _StarClipper(isHalf ? 0.5 : 1.0),
                child: Icon(
                  Icons.star_rate,
                  size: size,
                  color: AppColors.warning,
                ),
              ),
          ],
        );
      }),
    );
  }
}
