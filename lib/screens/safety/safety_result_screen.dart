import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/safety_result_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_buttons.dart';

/// Displays the result of the backend's safety/interaction check.
///
/// IMPORTANT: this screen only renders [SafetyResult] - all duplicate
/// ingredient detection and interaction logic lives on the backend.
class SafetyResultScreen extends ConsumerWidget {
  const SafetyResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(safetyCheckProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Safety Check')),
      body: SafeArea(
        child: resultAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Could not run the safety check.\n$err', textAlign: TextAlign.center),
            ),
          ),
          data: (result) => _SafetyResultView(result: result),
        ),
      ),
    );
  }
}

class _SafetyResultView extends ConsumerWidget {
  final SafetyResult result;
  const _SafetyResultView({required this.result});

  String get _headline {
    switch (result.overallLevel) {
      case SafetyLevel.green:
        return 'All Clear';
      case SafetyLevel.yellow:
        return 'Caution Advised';
      case SafetyLevel.red:
        return 'Action Needed';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = result.overallLevel.color;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(result.overallLevel.icon, color: color, size: 52),
              const SizedBox(height: 12),
              Text(
                _headline,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                result.summary,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (result.issues.isNotEmpty) ...[
          Text('Details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ...result.issues.map((issue) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(issue.level.icon, color: issue.level.color, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(issue.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(issue.detail, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
        const SizedBox(height: 10),
        PrimaryActionButton(
          label: 'Re-check',
          icon: Icons.refresh_rounded,
          onPressed: () => ref.invalidate(safetyCheckProvider),
        ),
      ],
    );
  }
}
