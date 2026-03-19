import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saluun_frontend/core/theme/app_design_system.dart';
import 'package:saluun_frontend/presentation/providers/auth_provider.dart';
import 'package:saluun_frontend/presentation/widgets/common_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user data')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Profile Picture
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: currentUser.profilePictureUrl != null
                  ? ClipOval(
                      child: Image.network(
                        currentUser.profilePictureUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.account_circle,
                        size: 120,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // User Info
            Center(
              child: Column(
                children: [
                  Text(
                    currentUser.displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    currentUser.email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.grey600),
                  ),
                  if (currentUser.phoneNumber != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      currentUser.phoneNumber!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Email Verification Status
            AppCard(
              child: Row(
                children: [
                  Icon(
                    currentUser.isEmailVerified
                        ? Icons.check_circle
                        : Icons.info,
                    color: currentUser.isEmailVerified
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Verification',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          currentUser.isEmailVerified
                              ? 'Your email is verified'
                              : 'Verify your email to unlock all features',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                  if (!currentUser.isEmailVerified)
                    TextButton(
                      onPressed: () {
                        // TODO: Implement email verification
                      },
                      child: const Text('Verify'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Account Settings
            AppCard(
              onTap: () {
                // TODO: Implement account settings
              },
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Settings',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          'Update your profile information',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Help & Support
            AppCard(
              onTap: () {
                // TODO: Implement help & support
              },
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Help & Support',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          'Contact our support team',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Logout Button
            SecondaryButton(
              label: 'Logout',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirmed ?? false) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
