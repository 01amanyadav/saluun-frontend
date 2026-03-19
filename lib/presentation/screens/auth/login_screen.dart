import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saluun_frontend/core/theme/app_design_system.dart';
import 'package:saluun_frontend/presentation/providers/auth_provider.dart';
import 'package:saluun_frontend/presentation/utils/form_validators.dart';
import 'package:saluun_frontend/presentation/widgets/common_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authProvider.notifier)
          .login(_emailController.text, _passwordController.text);

      // Navigate on success - check the auth state
      if (mounted) {
        final authState = ref.read(authProvider);
        final isSuccess =
            authState.whenData((user) => user != null).value == true;
        if (isSuccess) {
          context.go('/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sign in to continue booking your appointments',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.grey600),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: FormValidators.validateEmail,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                      validator: FormValidators.validatePassword,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    authState.when(
                      data: (_) => PrimaryButton(
                        label: 'Sign In',
                        onPressed: _handleLogin,
                      ),
                      loading: () => const PrimaryButton(
                        label: 'Sign In',
                        onPressed: null,
                        isLoading: true,
                      ),
                      error: (error, st) => Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
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
                            onPressed: _handleLogin,
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
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('Sign Up'),
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
