import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../widgets/widgets.dart';
import '../../profile/providers/dashboard_provider.dart';

class ReadingStatsScreen extends ConsumerWidget {
  const ReadingStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/reading-stats'),
      body: Container(
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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar.large(
                expandedHeight: 200,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  color: Colors.white,
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Reading Stats',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  background: Stack(
                    children: [
                      // Decorative elements
                      ...List.generate(3, (index) => Positioned(
                        right: -50 + (index * 100),
                        top: -50 + (index * 50),
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              // Reading Streak Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlassmorphicContainer(
                    height: 120,
                    borderRadius: 24,
                    borderWidth: 2,
                    blurRadius: 16,
                    linearGradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.2),
                        colorScheme.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Current Streak',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${state.currentStreak} days',
                            style: textTheme.headlineMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.2, end: 0),
                ),
              ),
              // Calendar Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlassmorphicContainer(
                    height: 500,
                    borderRadius: 24,
                    borderWidth: 2,
                    blurRadius: 16,
                    linearGradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.2),
                        colorScheme.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(DateTime.now().year, 1, 1),
                      lastDay: DateTime.utc(DateTime.now().year, 12, 31),
                      focusedDay: DateTime.now(),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        leftChevronIcon: Icon(Icons.chevron_left, color: colorScheme.primary),
                        rightChevronIcon: Icon(Icons.chevron_right, color: colorScheme.primary),
                        headerMargin: const EdgeInsets.only(bottom: 16),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.primary.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                        weekendStyle: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.primary.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        isTodayHighlighted: true,
                        defaultTextStyle: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        weekendTextStyle: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        selectedTextStyle: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        todayTextStyle: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        outsideTextStyle: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                        todayDecoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        defaultDecoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        weekendDecoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 1,
                        canMarkersOverflow: false,
                        markerSize: 6,
                        markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (state.readingDays.contains(date)) {
                            return Positioned(
                              bottom: 4,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primary,
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        // Could show details about the day reading activity or jump to logs
                      },
                      selectedDayPredicate: (day) => false,
                    ),
                  ).animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 