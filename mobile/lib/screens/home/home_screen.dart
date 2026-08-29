import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../my_medicines/my_medicines_screen.dart';
import '../profile/profile_screen.dart';
import '../safety/safety_result_screen.dart';
import '../scanner/scanner_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 1:
        return const MyMedicinesScreen();
      case 2:
        return const ScannerScreen();
      case 3:
        return const SafetyResultScreen();
      case 4:
        return const ProfileScreen();
      case 0:
      default:
        return _Dashboard(onNavigate: _selectTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        height: 72,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.medication_outlined), selectedIcon: Icon(Icons.medication_rounded), label: 'Medicines'),
          NavigationDestination(icon: Icon(Icons.document_scanner_outlined), selectedIcon: Icon(Icons.document_scanner_rounded), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.health_and_safety_outlined), selectedIcon: Icon(Icons.health_and_safety_rounded), label: 'Safety'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _Dashboard extends ConsumerWidget {
  final ValueChanged<int> onNavigate;
  const _Dashboard({required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageObjectProvider);
    final session = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(child: Text(language.nativeName, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white))),
        )],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(session.userName != null ? 'Hello, ${session.userName}!' : 'Hello!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('Your medicine safety companion', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Card(color: AppColors.primary, child: InkWell(
              borderRadius: BorderRadius.circular(20), onTap: () => onNavigate(2),
              child: const Padding(padding: EdgeInsets.all(24), child: Row(children: [
                Expanded(child: Text('Scan Medicine', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold))),
                Icon(Icons.document_scanner_rounded, color: Colors.white, size: 32),
              ])),
            )),
            const SizedBox(height: 28),
            Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            GridView.count(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.15, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: [
              HomeActionTile(label: 'My Medicines', subtitle: 'Saved strips', icon: Icons.medication_liquid_rounded, color: AppColors.secondary, onTap: () => onNavigate(1)),
              HomeActionTile(label: 'Safety Check', subtitle: 'Check interactions', icon: Icons.health_and_safety_rounded, color: AppColors.cautionYellow, onTap: () => onNavigate(3)),
              HomeActionTile(label: 'Voice Help', subtitle: 'Read guidance aloud', icon: Icons.record_voice_over_rounded, color: AppColors.primary, onTap: () { final voice = ref.read(voiceServiceProvider); final lang = ref.read(languageProvider); voice.speak('Welcome to Swasthya Seva. Tap Scan Medicine to check a medicine strip.', languageCode: lang); }),
              HomeActionTile(label: 'My Profile', subtitle: 'Theme and account', icon: Icons.person_rounded, color: AppColors.primaryDark, onTap: () => onNavigate(4)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class HomeActionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const HomeActionTile({super.key, required this.label, required this.subtitle, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(child: InkWell(
    borderRadius: BorderRadius.circular(16), onTap: onTap,
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 25, color: color)),
      const Spacer(), Text(label, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 3),
      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
    ])),
  ));
}
