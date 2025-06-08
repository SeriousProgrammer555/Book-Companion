
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Assuming AppScaffold is located at this path. Adjust if different.
import '../../../../widgets/app_scaffold.dart';

class ReadingStatsScreen extends ConsumerWidget {
  const ReadingStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final theme = Theme.of(context);

    return AppScaffold(
      scaffoldKey: scaffoldKey,
      title: 'Reading Stats',
      currentRoute: '/reading-stats',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Reading stats content
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading Progress',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  // Add your reading stats widgets here
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}