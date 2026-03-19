import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saluun_frontend/core/theme/app_design_system.dart';
import 'package:saluun_frontend/presentation/models/salon_details_ui_state.dart';
import 'package:saluun_frontend/presentation/providers/salon_provider.dart';
import 'package:saluun_frontend/presentation/widgets/common_widgets.dart';
import 'package:saluun_frontend/presentation/widgets/rating_stars.dart';
import 'package:saluun_frontend/presentation/widgets/salon_card.dart';
import 'package:saluun_frontend/presentation/widgets/service_card.dart';

/// Salon details screen displaying comprehensive salon information
///
/// Features:
/// - Salon image, name, location, and rating
/// - Detailed salon information (hours, contact)
/// - List of services with prices and durations
/// - Booking functionality for services
/// - Loading and error states
class SalonDetailsScreen extends ConsumerStatefulWidget {
  final String salonId;

  const SalonDetailsScreen({super.key, required this.salonId});

  @override
  ConsumerState<SalonDetailsScreen> createState() => _SalonDetailsScreenState();
}

class _SalonDetailsScreenState extends ConsumerState<SalonDetailsScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salonAsync = ref.watch(salonDetailsProvider(widget.salonId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () {
              // TODO: Implement favorite functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to favorites')),
              );
            },
          ),
        ],
      ),
      body: salonAsync.when(
        data: (salon) => _buildSalonDetails(context, salon),
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(
          context,
          error.toString(),
          onRetry: () {
            ref.refresh(salonDetailsProvider(widget.salonId));
          },
        ),
      ),
    );
  }

  /// Build salon details content
  Widget _buildSalonDetails(BuildContext context, salonData) {
    final salon = salonData;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Salon Image
          if (salon.image != null)
            Image.network(
              salon.image!,
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 280,
                  color: AppColors.grey100,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined, size: 48),
                  ),
                );
              },
            )
          else
            Container(
              height: 280,
              color: AppColors.grey100,
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined, size: 48),
              ),
            ),

          // Salon Info Section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salon.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.grey600,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  salon.location,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.grey600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Rating Section
                RatingStars(
                  rating: salon.rating,
                  reviewCount: salon.reviewCount,
                  size: 18,
                  showReviewCount: true,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Description
                if (salon.description != null &&
                    salon.description!.isNotEmpty) ...[
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    salon.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey700,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Contact & Hours
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phone
                      if (salon.phone != null)
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Phone',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppColors.grey600),
                                  ),
                                  Text(
                                    salon.phone!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.call_outlined),
                              onPressed: () {
                                // TODO: Implement call functionality
                              },
                            ),
                          ],
                        ),

                      if (salon.phone != null && salon.openingTime != null)
                        const Divider(height: AppSpacing.lg),

                      // Hours
                      if (salon.openingTime != null &&
                          salon.closingTime != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Operating Hours',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.grey600),
                                ),
                                Text(
                                  '${salon.openingTime} - ${salon.closingTime}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Services Section
                Text(
                  'Our Services',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.md),

                // Services List
                _buildServicesSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build services list section
  Widget _buildServicesSection(BuildContext context) {
    final servicesAsync = ref.watch(salonServicesProvider(widget.salonId));

    return servicesAsync.when(
      data: (services) {
        if (services.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Column(
                children: [
                  Icon(Icons.spa_outlined, size: 48, color: AppColors.grey300),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No services available',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: AppColors.grey600),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, index) {
            final service = services[index];
            return ServiceCard(
              service: service,
              onTap: () {
                // TODO: Show service details
              },
              onBookTap: () {
                // TODO: Navigate to booking screen
                // context.push('/booking?salonId=${widget.salonId}&serviceId=${service.id}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking coming soon')),
                );
              },
            );
          },
        );
      },
      loading: () => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (_, __) => const ServiceCardShimmer(),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load services',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                ref.refresh(salonServicesProvider(widget.salonId));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading state UI
  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image shimmer
          Container(height: 280, color: AppColors.grey200),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name shimmer
                Container(
                  height: 20,
                  width: 250,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Location shimmer
                Container(
                  height: 16,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Rating shimmer
                Container(
                  height: 16,
                  width: 150,
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

  /// Build error state UI
  Widget _buildErrorState(
    BuildContext context,
    String errorMessage, {
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to load salon details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Try Again', onPressed: onRetry, width: 150),
          ],
        ),
      ),
    );
  }
}
