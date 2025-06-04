import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dashboard_provider.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedTimeRange = ref.watch(dashboardProvider).selectedTimeRange;

    return SliverAppBar.large(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 24, bottom: 16),
        centerTitle: false,
        title: Text(
          'My Reading Diary',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
              ],
            ),
          ),
          child: Stack(
            children: [
              ...List.generate(3, (index) => Positioned(
                right: -50 + (index * 100),
                top: -50 + (index * 50),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              )),
              _buildDateSelector(context, colorScheme, textTheme),
              _buildWelcomeSection(context, colorScheme, textTheme, selectedTimeRange, ref),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Show notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Positioned.fill(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_rounded, size: 16, color: colorScheme.onPrimary),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('d MMM').format(DateTime.now()),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colorScheme.onPrimary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    String selectedTimeRange,
    WidgetRef ref,
  ) {
    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back!',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your reading journey',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'This Week',
                      label: Text('Week'),
                    ),
                    ButtonSegment(
                      value: 'This Month',
                      label: Text('Month'),
                    ),
                    ButtonSegment(
                      value: 'This Year',
                      label: Text('Year'),
                    ),
                  ],
                  selected: {selectedTimeRange},
                  onSelectionChanged: (Set<String> newSelection) {
                    ref.read(dashboardProvider.notifier).updateTimeRange(newSelection.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      colorScheme.onPrimary.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 