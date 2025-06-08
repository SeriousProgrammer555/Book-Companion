import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../widgets/app_scaffold.dart';
import '../../../widgets/glassmorphic_container.dart';
import '../../profile/providers/dashboard_provider.dart';

class ReadingStatsScreen extends ConsumerWidget {
  const ReadingStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return AppScaffold(
      scaffoldKey: scaffoldKey,
      title: 'Reading Stats',
      currentRoute: '/reading-stats',
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
              colorScheme.background,
            ],
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reading Overview
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: GlassmorphicContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reading Overview',
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                context,
                                '${state.currentStreak}',
                                'Day Streak',
                                Icons.local_fire_department,
                                Colors.orange,
                              ),
                              _buildStatCard(
                                context,
                                '${state.completedBooks.length}',
                                'Books Read',
                                Icons.menu_book,
                                Colors.blue,
                              ),
                              _buildStatCard(
                                context,
                                '${state.dailyProgress}',
                                'Min Today',
                                Icons.timer,
                                Colors.green,
                              ),
                            ],
                          ).animate().fadeIn().slideY(begin: 0.2, end: 0, delay: 200.ms),
                        ],
                      ),
                    ),
                  ),

                  // Reading Calendar
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: GlassmorphicContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reading Calendar',
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                          const SizedBox(height: 20),
                          TableCalendar(
                            firstDay: DateTime.utc(2024, 1, 1),
                            lastDay: DateTime.utc(2024, 12, 31),
                            focusedDay: DateTime.now(),
                            calendarFormat: CalendarFormat.month,
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: textTheme.titleMedium!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                              rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
                            ),
                            calendarStyle: CalendarStyle(
                              defaultTextStyle: const TextStyle(color: Colors.white),
                              weekendTextStyle: const TextStyle(color: Colors.white70),
                              outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              todayDecoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                        ],
                      ),
                    ),
                  ),

                  // Reading Goals
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: GlassmorphicContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reading Goals',
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                          const SizedBox(height: 20),
                          _buildGoalProgress(
                            context,
                            'Daily Reading',
                            '30 minutes',
                            0.7,
                            Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          _buildGoalProgress(
                            context,
                            'Books This Month',
                            '2 of 4 books',
                            0.5,
                            Colors.green,
                          ),
                          const SizedBox(height: 16),
                          _buildGoalProgress(
                            context,
                            'Pages This Week',
                            '156 of 300 pages',
                            0.52,
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: isSmallScreen ? 20 : 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGoalProgress(
    BuildContext context,
    String title,
    String subtitle,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
} 