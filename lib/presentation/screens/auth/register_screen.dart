import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saluun_frontend/core/theme/app_design_system.dart';
import 'package:saluun_frontend/presentation/providers/auth_provider.dart';
import 'package:saluun_frontend/presentation/utils/form_validators.dart';
import 'package:saluun_frontend/presentation/widgets/common_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();
  double _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _passwordController.addListener(() {
      setState(() {
        _passwordStrength = PasswordStrength.calculateStrength(
          _passwordController.text,
        );
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authProvider.notifier)
          .register(
            _emailController.text,
            _passwordController.text,
            _nameController.text,
          );

      // Navigate on success
      if (mounted &&
              ref.read(authProvider).whenData((user) => user != null).value ??
          false) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join Us Today',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Create an account to start booking appointments',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.grey600),
              ),
              const SizedBox(height: AppSpacing.xl),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                      validator: FormValidators.validateDisplayName,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: FormValidators.validateEmail,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
                          style: AppTypography.labelLarge.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          validator: FormValidators.validatePassword,
                          decoration: InputDecoration(
                            hintText: 'Create a strong password',
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                                child: LinearProgressIndicator(
                                  value: _passwordStrength,
                                  minHeight: 4,
                                  backgroundColor: AppColors.grey200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _passwordStrength < 0.3
                                        ? AppColors.error
                                        : _passwordStrength < 0.6
                                        ? AppColors.warning
                                        : _passwordStrength < 0.8
                                        ? AppColors.success
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              PasswordStrength.getStrengthLabel(
                                _passwordStrength,
                              ),
                              style: AppTypography.labelSmall.copyWith(
                                color: _passwordStrength < 0.3
                                    ? AppColors.error
                                    : _passwordStrength < 0.6
                                    ? AppColors.warning
                                    : _passwordStrength < 0.8
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (value) =>
                          FormValidators.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    authState.when(
                      data: (_) => PrimaryButton(
                        label: 'Create Account',
                        onPressed: _handleRegister,
                      ),
                      loading: () => const PrimaryButton(
                        label: 'Creating Account...',
                        onPressed: null,
                        isLoading: true,
                      ),
                      error: (error, st) => Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Text(
                              error.toString(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.error),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          PrimaryButton(
                            label: 'Try Again',
                            onPressed: _handleRegister,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
