import 'package:flutter/material.dart';
import 'package:saluun_frontend/core/theme/app_design_system.dart';
import 'package:saluun_frontend/domain/entities/salon_entity.dart';

/// Reusable SalonCard widget for displaying salon information
///
/// Displays salon image, name, location, rating, and operating hours
/// in a cards-based Material 3 design
class SalonCard extends StatelessWidget {
  final SalonEntity salon;
  final VoidCallback? onTap;
  final bool showDescription;

  const SalonCard({
    super.key,
    required this.salon,
    this.onTap,
    this.showDescription = true,
  });

  /// Determine if salon is currently open based on operating hours
  /// This is a simple check - production would need proper time zone handling
  bool _isSalonOpen() {
    // For now, return true as a placeholder
    // In production, compare current time with openingTime and closingTime
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = _isSalonOpen();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: AppColors.grey200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Stack(
              children: [
                // Salon Image
                if (salon.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.md),
                      topRight: Radius.circular(AppRadius.md),
                    ),
                    child: Image.network(
                      salon.image!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    ),
                  )
                else
                  _buildImagePlaceholder(height: 180),

                // Rating Badge
                if (salon.rating != null)
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            salon.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Status Badge
                Positioned(
                  bottom: AppSpacing.md,
                  left: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? AppColors.success.withOpacity(0.9)
                          : AppColors.grey600.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      isOpen ? 'Open' : 'Closed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    salon.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.grey600,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          salon.location,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Description (optional)
                  if (showDescription && salon.description != null) ...[
                    Text(
                      salon.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Operating Hours
                  if (salon.openingTime != null && salon.closingTime != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.grey600,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${salon.openingTime} - ${salon.closingTime}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey600),
                        ),
                      ],
                    ),

                  const SizedBox(height: AppSpacing.md),

                  // Rating and Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Number of reviews
                      if (salon.reviewCount != null)
                        Row(
                          children: [
                            Text(
                              '${salon.reviewCount}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'reviews',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.grey600),
                            ),
                          ],
                        )
                      else
                        Text(
                          'No reviews yet',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey600),
                        ),

                      // Call button
                      if (salon.phone != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Call',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build placeholder when image is not available
  Widget _buildImagePlaceholder({double height = 180}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.md),
          topRight: Radius.circular(AppRadius.md),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: AppColors.grey400,
        ),
      ),
    );
  }
}

/// Shimmer loading placeholder for SalonCard
class SalonCardShimmer extends StatelessWidget {
  const SalonCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: AppColors.grey200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer Image
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
              ),
            ),
          ),

          // Shimmer Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name shimmer
                Container(
                  height: 16,
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Location shimmer
                Container(
                  height: 12,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Description shimmer
                Column(
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: 12,
                      width: 250,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Hours shimmer
                Container(
                  height: 12,
                  width: 180,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
