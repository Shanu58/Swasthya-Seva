import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),

            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                session.userName ?? 'Guest User',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            const SizedBox(height: 6),

            Center(
              child: Text(
                session.isGuest
                    ? 'You are currently using a guest account'
                    : 'Your health profile',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 28),

            _SectionTitle(title: 'Personal Information'),

            const SizedBox(height: 12),

            _ProfileCard(
              children: [
                _ProfileRow(
                  icon: Icons.cake_outlined,
                  label: 'Age',
                  value: 'Not added',
                ),
                const Divider(height: 1),
                _ProfileRow(
                  icon: Icons.height_rounded,
                  label: 'Height',
                  value: 'Not added',
                ),
                const Divider(height: 1),
                _ProfileRow(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  value: 'Not added',
                ),
              ],
            ),

            const SizedBox(height: 28),

            _SectionTitle(title: 'Appearance'),

            const SizedBox(height: 12),

            _ProfileCard(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: Text(
                    themeMode == ThemeMode.dark
                        ? 'Dark theme is enabled'
                        : 'Light theme is enabled',
                  ),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) {
                    ref.read(themeModeProvider.notifier).toggle();
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            _SectionTitle(title: 'Account'),

            const SizedBox(height: 12),

            _ProfileCard(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final List<Widget> children;

  const _ProfileCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(label),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
