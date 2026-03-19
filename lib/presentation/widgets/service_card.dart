import 'package:flutter/material.dart';
import 'package:saluun_frontend/core/theme/app_design_system.dart';
import 'package:saluun_frontend/domain/entities/service_entity.dart';

/// Reusable service card widget for displaying service information
///
/// Displays service name, description, price, duration, and category
/// in a cards-based Material 3 design
class ServiceCard extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback? onTap;
  final VoidCallback? onBookTap;
  final bool showBookButton;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onBookTap,
    this.showBookButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: AppColors.grey200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PKR ${service.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (service.durationMinutes != null)
                        Text(
                          '${service.durationMinutes} min',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey600),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Description
              if (service.description != null &&
                  service.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),

              // Service details row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category badge
                  if (service.category != null && service.category!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        service.category!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // Popularity indicator
                  if (service.popularity != null && service.popularity! > 0)
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${service.popularity}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                ],
              ),

              // Book button
              if (showBookButton && onBookTap != null) ...[
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onBookTap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading placeholder for ServiceCard
class ServiceCardShimmer extends StatelessWidget {
  const ServiceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: AppColors.grey200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and price shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Name shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 180,
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        height: 14,
                        width: 250,
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    ],
                  ),
                ),
                // Price shimmer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 16,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: 12,
                      width: 60,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

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
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Category and button shimmer
            Row(
              children: [
                Container(
                  height: 28,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
