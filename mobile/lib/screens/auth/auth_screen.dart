import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_buttons.dart';
import '../home/home_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _emailController =
      TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();

    setState(() {
      _error = null;
    });

    if (email.isEmpty) {
      setState(() {
        _error = 'Please enter your email address.';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _error = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final api =
          ref.read(apiServiceProvider);

      final user =
          await api.findUserByEmail(email);

      if (user == null) {
        if (!mounted) return;

        await _showCreateAccountDialog(
          email,
        );
        return;
      }

      await ref
          .read(sessionProvider.notifier)
          .signIn(
            userId: user.id,
            userName: user.name,
          );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            'Could not connect to the server. Please make sure the backend is running.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showCreateAccountDialog(
    String email,
  ) async {
    final nameController =
        TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Create Account',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No account was found for $email.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                textCapitalization:
                    TextCapitalization.words,
                decoration:
                    const InputDecoration(
                  labelText: 'Your name',
                  prefixIcon:
                      Icon(Icons.person_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text
                    .trim()
                    .isEmpty) {
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Create',
              ),
            ),
          ],
        );
      },
    );

    if (created != true) return;

    final name =
        nameController.text.trim();

    try {
      final api =
          ref.read(apiServiceProvider);

      final user =
          await api.createUser(
        name: name,
        email: email,
      );

      await ref
          .read(sessionProvider.notifier)
          .signIn(
            userId: user.id,
            userName: user.name,
          );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            'Could not create your account. Please try again.';
      });
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref
          .read(sessionProvider.notifier)
          .continueAsGuest();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              const Icon(
                Icons.health_and_safety_rounded,
                size: 64,
                color: AppColors.primary,
              ),

              const SizedBox(height: 20),

              Text(
                'Welcome to ${AppConstants.appName}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),

              const SizedBox(height: 10),

              Text(
                'Scan medicines, verify them, and check important safety information.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),

              const Spacer(),

              TextField(
                controller: _emailController,
                keyboardType:
                    TextInputType.emailAddress,
                enabled: !_isLoading,
                onSubmitted: (_) =>
                    _signIn(),
                decoration:
                    const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 10),

                Text(
                  _error!,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        AppColors.dangerRed,
                  ),
                ),
              ],

              const SizedBox(height: 14),

              SecondaryActionButton(
                label: 'Sign In',
                icon: Icons.login_rounded,
                onPressed: _isLoading
                    ? null
                    : _signIn,
              ),

              const SizedBox(height: 14),

              PrimaryActionButton(
                label: 'Continue as Guest',
                icon:
                    Icons.arrow_forward_rounded,
                onPressed: _isLoading
                    ? null
                    : _continueAsGuest,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
