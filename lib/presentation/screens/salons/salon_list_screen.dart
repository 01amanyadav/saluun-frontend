import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saluun_frontend/core/theme/app_design_system.dart';
import 'package:saluun_frontend/presentation/providers/salon_provider.dart';
import 'package:saluun_frontend/presentation/widgets/common_widgets.dart';
import 'package:saluun_frontend/presentation/widgets/salon_card.dart';

/// Salon list screen with search, filters, and Material 3 design
///
/// Features:
/// - Search bar for salon name/location
/// - Rating filter chips
/// - Sort options (rating, reviews, name)
/// - Shimmer loading UI
/// - Error state with retry
/// - Empty state with helpful message
class SalonListScreen extends ConsumerStatefulWidget {
  const SalonListScreen({super.key});

  @override
  ConsumerState<SalonListScreen> createState() => _SalonListScreenState();
}

class _SalonListScreenState extends ConsumerState<SalonListScreen> {
  late TextEditingController _searchController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(salonSearchQueryProvider);
    final ratingFilter = ref.watch(ratingFilterProvider);
    final sortBy = ref.watch(sortByProvider);
    final salonsAsync = ref.watch(filteredSalonsProvider);
    final ratingOptions = ref.watch(ratingFiltersProvider);
    final sortOptions = ref.watch(sortOptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salons'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              _SearchBar(
                controller: _searchController,
                onChanged: (query) {
                  ref.read(salonSearchQueryProvider.notifier).state = query;
                },
                onClear: () {
                  _searchController.clear();
                  ref.read(salonSearchQueryProvider.notifier).state = '';
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Filter Toggle Button
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _showFilters = !_showFilters);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _showFilters
                                  ? Icons.filter_alt
                                  : Icons.filter_alt_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Filters',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (ratingFilter != null || sortBy != null) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: Text(
                                  '${(ratingFilter != null ? 1 : 0) + (sortBy != null ? 1 : 0)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Clear filters button
                  if (ratingFilter != null || sortBy != null)
                    TextButton(
                      onPressed: () {
                        ref.read(ratingFilterProvider.notifier).state = null;
                        ref.read(sortByProvider.notifier).state = null;
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),

              // Expandable Filters Section
              if (_showFilters) ...[
                const SizedBox(height: AppSpacing.md),
                _FilterSection(
                  title: 'Rating',
                  options: ratingOptions,
                  selectedValue: ratingFilter,
                  onOptionSelected: (value) {
                    ref.read(ratingFilterProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _FilterSection(
                  title: 'Sort By',
                  options: sortOptions,
                  selectedValue: sortBy,
                  onOptionSelected: (value) {
                    ref.read(sortByProvider.notifier).state = value;
                  },
                  isMultiSelect: false,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Salons List or States
              salonsAsync.when(
                data: (salons) {
                  if (salons.isEmpty) {
                    return _buildEmptyState(context, searchQuery);
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: salons.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (context, index) {
                      final salon = salons[index];
                      return SalonCard(
                        salon: salon,
                        onTap: () => context.push('/salon/${salon.id}'),
                        showDescription: true,
                      );
                    },
                  );
                },
                loading: () => _buildShimmerLoading(),
                error: (error, stackTrace) => _buildErrorState(
                  context,
                  error.toString(),
                  onRetry: () {
                    // ignore: cascade_invocations
                    ref.refresh(filteredSalonsProvider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build empty state UI
  Widget _buildEmptyState(BuildContext context, String searchQuery) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl * 2),
        child: EmptyStateWidget(
          icon: Icons.store_outlined,
          title: searchQuery.isEmpty ? 'No Salons Found' : 'No Results',
          message: searchQuery.isEmpty
              ? 'No salons available at the moment.\nTry again later!'
              : 'No salons match your search.\nTry a different search term.',
          buttonLabel: searchQuery.isEmpty ? null : 'Clear Search',
          onButtonPressed: searchQuery.isEmpty
              ? null
              : () {
                  _searchController.clear();
                  ref.read(salonSearchQueryProvider.notifier).state = '';
                },
        ),
      ),
    );
  }

  /// Build shimmer loading UI
  Widget _buildShimmerLoading() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        return const SalonCardShimmer();
      },
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl * 2),
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
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Try Again', onPressed: onRetry, width: 150),
          ],
        ),
      ),
    );
  }
}

/// Search bar widget with Material 3 design
class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: widget.controller,
      hintText: 'Search salons by name or location...',
      onChanged: widget.onChanged,
      backgroundColor: WidgetStateProperty.all(AppColors.grey50),
      leading: const Padding(
        padding: EdgeInsets.only(left: AppSpacing.md),
        child: Icon(Icons.search),
      ),
      trailing: widget.controller.text.isNotEmpty
          ? [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onClear();
                  },
                ),
              ),
            ]
          : [],
    );
  }
}

/// Filter section widget for rating and sort options
class _FilterSection extends StatelessWidget {
  final String title;
  final List<Map<String, String>> options;
  final String? selectedValue;
  final Function(String?) onOptionSelected;
  final bool isMultiSelect;

  const _FilterSection({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onOptionSelected,
    this.isMultiSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: options.map((option) {
            final isSelected = selectedValue == option['value'];
            return FilterChip(
              label: Text(option['label'] ?? ''),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onOptionSelected(option['value']);
                } else if (isMultiSelect) {
                  onOptionSelected(null);
                }
              },
              backgroundColor: Colors.transparent,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.grey300,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.grey700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              showCheckmark: true,
            );
          }).toList(),
        ),
      ],
    );
  }
}
