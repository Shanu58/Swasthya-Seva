import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_buttons.dart';
import '../home/home_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      AppUser? user = await api.findUserByEmail(email);

      if (user == null) {
        final localPart = email.split('@').first.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), ' ').trim();
        final name = localPart.isEmpty ? 'Swasthya Seva User' : localPart[0].toUpperCase() + localPart.substring(1);
        user = await api.createUser(name: name, email: email);
      }

      await ref.read(sessionProvider.notifier).signIn(
        userId: user.id,
        userName: user.name,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not sign in. Make sure the backend is running and reachable.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Sign in with your email to keep your profile connected to your account.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                onSubmitted: (_) => _isLoading ? null : _signIn(),
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: AppColors.dangerRed)),
              ],
              const SizedBox(height: 14),
              PrimaryActionButton(
                label: _isLoading ? 'Signing In...' : 'Sign In',
                icon: Icons.login_rounded,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _signIn,
              ),
              const SizedBox(height: 14),
              SecondaryActionButton(
                label: 'Continue as Guest',
                icon: Icons.arrow_forward_rounded,
                onPressed: _isLoading
                    ? null
                    : () async {
                        await ref.read(sessionProvider.notifier).continueAsGuest();
                        if (!mounted) return;
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
