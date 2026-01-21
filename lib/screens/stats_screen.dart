import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/done_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_manager.dart';
import '../services/category_service.dart';
import 'settings_screen.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: theme.colorScheme.onSurface,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              isScrollable: false,
              tabs: const [
                Tab(
                  icon: Icon(Icons.dashboard, size: 24),
                ),
                Tab(
                  icon: Icon(Icons.bar_chart, size: 24),
                ),
                Tab(
                  icon: Icon(Icons.calendar_today, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SummaryTab(),
          GraphTab(),
          CalendarTab(),
        ],
      ),
    );
  }
}

// サマリータブ
class SummaryTab extends ConsumerWidget {
  const SummaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doneListAsync = ref.watch(doneListProvider);
    
    if (doneListAsync.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentOrange,
        ),
      );
    }
    
    if (doneListAsync.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'データの読み込みに失敗しました',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    
    final totalCount = ref.watch(totalDoneCountProvider);
    final weeklyCount = ref.watch(weeklyDoneCountProvider);
    final streak = ref.watch(streakProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // メインカード
          Builder(
            builder: (context) {
              final themeType = ref.watch(themeTypeProvider);
              final themeStyle = ThemeManager.getThemeStyle(themeType);
              final theme = Theme.of(context);
              
              return Container(
                width: double.infinity,
                padding: themeStyle.cardPadding,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(themeStyle.cardBorderRadius),
                  boxShadow: themeStyle.useBoldShadows
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Text(
                      '累計Done数',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalCount',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // 統計カード
          Builder(
            builder: (context) {
              final themeType = ref.watch(themeTypeProvider);
              final themeStyle = ThemeManager.getThemeStyle(themeType);
              final theme = Theme.of(context);
              
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '今週のDone数',
                      '$weeklyCount',
                      Icons.calendar_today,
                      theme.colorScheme.secondary,
                      themeStyle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '連続日数',
                      '$streak',
                      Icons.local_fire_department,
                      theme.colorScheme.primary,
                      themeStyle,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // 詳細情報カード
          Builder(
            builder: (context) {
              final themeType = ref.watch(themeTypeProvider);
              final themeStyle = ThemeManager.getThemeStyle(themeType);
              final theme = Theme.of(context);
              
              return Container(
                width: double.infinity,
                padding: themeStyle.cardPadding,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(themeStyle.cardBorderRadius),
                  boxShadow: themeStyle.useBoldShadows
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.accentBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '統計情報',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow('累計Done数', '$totalCount 件'),
                const Divider(height: 24),
                _buildInfoRow('今週のDone数', '$weeklyCount 件'),
                const Divider(height: 24),
                _buildInfoRow('最大連続継続日数', '$streak 日'),
              ],
            ),
              );
            },
          ),

          const SizedBox(height: 24),

          // カテゴリー別統計
          Builder(
            builder: (context) {
              final themeType = ref.watch(themeTypeProvider);
              final themeStyle = ThemeManager.getThemeStyle(themeType);
              final theme = Theme.of(context);
              
              return Container(
                width: double.infinity,
                padding: themeStyle.cardPadding,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(themeStyle.cardBorderRadius),
                  boxShadow: themeStyle.useBoldShadows
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'カテゴリー別統計',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._buildCategoryStats(ref),
              ],
            ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryStats(WidgetRef ref) {
    final doneList = ref.watch(doneListProvider).value ?? [];
    final categoryCounts = <String, int>{};

    for (var item in doneList) {
      final category = item.category.isNotEmpty 
          ? item.category 
          : Category.uncategorized;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    final categories = [
      Category.work,
      Category.growth,
      Category.hobby,
      Category.health,
      Category.life,
      Category.uncategorized,
    ];

    return categories.map((category) {
      final count = categoryCounts[category] ?? 0;
      final percentage = doneList.isEmpty
          ? 0.0
          : (count / doneList.length * 100);
      final color = Color(AsyncCategoryService.getCategoryColor(category));

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Builder(
                      builder: (context) => Text(
                        AsyncCategoryService.getCategoryName(category),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                Builder(
                  builder: (context) => Text(
                    '$count件 (${percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: doneList.isEmpty ? 0 : count / doneList.length,
                backgroundColor: AppTheme.lightGray,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeStyle themeStyle,
  ) {
    return Container(
      padding: themeStyle.cardPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(themeStyle.cardBorderRadius),
        boxShadow: themeStyle.useBoldShadows
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.darkGray,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textBlack,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// グラフタブ
class GraphTab extends ConsumerWidget {
  const GraphTab({super.key});

  String _getWeekdayShort(int weekday) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[weekday - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doneListAsync = ref.watch(doneListProvider);
    
    if (doneListAsync.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentOrange,
        ),
      );
    }
    
    final weeklyStats = ref.watch(weeklyStatsProvider);
    
    if (weeklyStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: AppTheme.darkGray.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'データがありません',
              style: TextStyle(color: AppTheme.darkGray),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダーカード
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.baseWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: AppTheme.accentOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '直近7日間のDone数',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '日々の活動を可視化',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // グラフカード
          Builder(
            builder: (context) {
              final themeType = ref.watch(themeTypeProvider);
              final themeStyle = ThemeManager.getThemeStyle(themeType);
              final theme = Theme.of(context);
              
              return Container(
                width: double.infinity,
                padding: themeStyle.cardPadding,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(themeStyle.cardBorderRadius),
                  boxShadow: themeStyle.useBoldShadows
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 300,
                      child: Padding(
                        padding: themeStyle.graphPadding,
                        child: BarChart(
                          BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: () {
                        if (weeklyStats.isEmpty) return 10.0;
                        try {
                          final counts = weeklyStats
                              .map((e) => (e['count'] as int? ?? 0))
                              .where((count) => count >= 0)
                              .toList();
                          if (counts.isEmpty) return 10.0;
                          final maxCount = counts.reduce((a, b) => a > b ? a : b);
                          return (maxCount + 2).toDouble();
                        } catch (e) {
                          return 10.0;
                        }
                      }(),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (group) => theme.colorScheme.primary,
                                tooltipRoundedRadius: themeStyle.cardBorderRadius / 4,
                                tooltipPadding: const EdgeInsets.all(8),
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '${rod.toY.toInt()}',
                                    TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              try {
                                final index = value.toInt();
                                if (index >= 0 && index < weeklyStats.length) {
                                  final date = weeklyStats[index]['date'] as DateTime?;
                                  if (date != null) {
                                    final weekdays = ['月', '火', '水', '木', '金', '土', '日'];
                                    final weekday = weekdays[date.weekday - 1];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${date.month}/${date.day}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.darkGray,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            weekday,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: AppTheme.darkGray,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                // エラーが発生した場合は空文字を返す
                              }
                              return const Text('');
                            },
                            reservedSize: 60,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.darkGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                            gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: theme.colorScheme.surfaceContainerHighest,
                            strokeWidth: themeStyle.graphLineWidth,
                          );
                        },
                      ),
                            borderData: FlBorderData(show: false),
                            barGroups: weeklyStats.isEmpty
                          ? []
                          : weeklyStats.asMap().entries.map((entry) {
                              final index = entry.key;
                              final data = entry.value;
                              try {
                                final count = (data['count'] as int? ?? 0).toDouble();
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: count,
                                      color: theme.colorScheme.primary,
                                      width: themeStyle.graphBarWidth,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                          themeStyle.cardBorderRadius / 4,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } catch (e) {
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 0,
                                      color: theme.colorScheme.primary,
                                      width: themeStyle.graphBarWidth,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                          themeStyle.cardBorderRadius / 4,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // 統計サマリー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.baseWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '週間サマリー',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 16),
                ...weeklyStats.map((stat) {
                  final date = stat['date'] as DateTime? ?? DateTime.now();
                  final count = stat['count'] as int? ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${date.month}/${date.day}(${_getWeekdayShort(date.weekday)})',
                          style: const TextStyle(
                            color: AppTheme.darkGray,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 100,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppTheme.lightGray,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (count / 10).clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.accentOrange,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$count',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// カレンダータブ
class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({super.key});

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final doneListAsync = ref.watch(doneListProvider);
    
    if (doneListAsync.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentOrange,
        ),
      );
    }
    
    final datesWithDone = ref.watch(datesWithDoneProvider);
    final selectedDayList = ref.watch(doneByDateProvider(_selectedDay));

    return Column(
      children: [
        // カレンダー
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.baseWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                eventLoader: (day) {
                  final date = DateTime(day.year, day.month, day.day);
                  return datesWithDone.contains(date) ? [1] : [];
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textBlack,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ),

        // 選択した日のDoneリスト
        if (selectedDayList.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: AppTheme.baseWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.accentOrange,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDay.year}年${_selectedDay.month}月${_selectedDay.day}日',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${selectedDayList.length}件',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedDayList.length,
                    itemBuilder: (context, index) {
                      final item = selectedDayList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.accentBlue,
                          child: const Icon(
                            Icons.check,
                            color: AppTheme.baseWhite,
                            size: 20,
                          ),
                        ),
                        title: Text(item.text),
                        subtitle: Text(
                          DateFormat('HH:mm').format(item.createdAt),
                          style: const TextStyle(
                            color: AppTheme.darkGray,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
