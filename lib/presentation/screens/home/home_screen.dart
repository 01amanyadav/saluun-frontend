import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saluun_frontend/core/theme/app_design_system.dart';
import 'package:saluun_frontend/presentation/providers/auth_provider.dart';
import 'package:saluun_frontend/presentation/providers/salon_provider.dart';
import 'package:saluun_frontend/presentation/providers/booking_provider.dart';
import 'package:saluun_frontend/presentation/widgets/common_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final bookingsAsync = ref.watch(bookingsProvider);
    final salonsAsync = ref.watch(salonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saluun'),
        titleSpacing: AppSpacing.lg,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              context.push('/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${currentUser?.displayName ?? "Guest"}!',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Ready to book your next appointment?',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Upcoming',
                      value: _getUpcomingCount(bookingsAsync),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle_outline,
                      title: 'Completed',
                      value: _getCompletedCount(bookingsAsync),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Recent Bookings
              Text(
                'Recent Bookings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              bookingsAsync.when(
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.bookmark_outline,
                      title: 'No Bookings Yet',
                      message:
                          'You haven\'t made any bookings yet. Browse salons to get started!',
                      buttonLabel: 'Browse Salons',
                      onButtonPressed: () => context.push('/salons'),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookings.take(3).length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return AppCard(
                        onTap: () => context.push('/booking/${booking.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking.salonName,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        booking.serviceType,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.grey600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: booking.status == 'confirmed'
                                        ? AppColors.success.withOpacity(0.1)
                                        : AppColors.warning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: Text(
                                    booking.status.toUpperCase(),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: booking.status == 'confirmed'
                                          ? AppColors.success
                                          : AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: AppColors.grey600,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '${booking.bookingTime.day}/${booking.bookingTime.month} at ${booking.bookingTime.hour}:${booking.bookingTime.minute.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.grey600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
                error: (error, st) => ErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.refresh(bookingsProvider),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Explore Salons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Salons',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.push('/salons'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              salonsAsync.when(
                data: (salons) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: salons.take(3).length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final salon = salons[index];
                      return AppCard(
                        onTap: () => context.push('/salon/${salon.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (salon.photoUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                child: Image.network(
                                  salon.photoUrl!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  color: AppColors.grey200,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        salon.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        salon.address,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.grey600,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: AppColors.warning,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(
                                          salon.rating.toStringAsFixed(1),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelLarge,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${salon.reviewCount} reviews',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColors.grey600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
                error: (error, st) => ErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.refresh(salonsProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getUpcomingCount(AsyncValue bookings) {
    return bookings.whenData((list) {
          return list
              .where((b) => b.bookingTime.isAfter(DateTime.now()))
              .length;
        }).value ??
        0;
  }

  int _getCompletedCount(AsyncValue bookings) {
    return bookings.whenData((list) {
          return list.where((b) => b.status == 'completed').length;
        }).value ??
        0;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.md),
          Text(value.toString(), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}
