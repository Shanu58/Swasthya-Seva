import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_buttons.dart';
import '../home/home_screen.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  void _showSignInComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In'),
        content: const Text(
          'Account sign-in will be available soon. For now, please continue as a guest to try the full demo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.health_and_safety_rounded, size: 64, color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                'Welcome to ${AppConstants.appName}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Scan any medicine to verify it\'s genuine, check its expiry, and stay safe from harmful drug interactions.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),

              // Sign-in form - present, but never blocks the demo flow.
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Phone number or email',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                onTap: () {},
              ),
              const SizedBox(height: 14),
              SecondaryActionButton(
                label: 'Sign In',
                icon: Icons.login_rounded,
                onPressed: () => _showSignInComingSoon(context),
              ),
              const SizedBox(height: 14),
              PrimaryActionButton(
                label: 'Continue as Guest',
                icon: Icons.arrow_forward_rounded,
                onPressed: () async {
                  await ref.read(sessionProvider.notifier).continueAsGuest();
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
