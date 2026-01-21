import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/badge_provider.dart';
import '../services/badge_service.dart';
import '../services/category_service.dart';
import '../providers/theme_provider.dart';
import '../theme/theme_manager.dart';
import '../models/badge.dart' as models;

class BadgeScreen extends ConsumerStatefulWidget {
  const BadgeScreen({super.key});

  @override
  ConsumerState<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends ConsumerState<BadgeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final List<String> _categories = [
    Category.work,
    Category.growth,
    Category.hobby,
    Category.health,
    Category.life,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeList = ref.watch(badgeListProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('バッジ'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          tabs: _categories.map((category) {
            return Tab(
              text: AsyncCategoryService.getCategoryName(category),
            );
          }).toList(),
        ),
      ),
      body: badgeList.when(
        data: (badges) {
          final badgeModels = badges.cast<models.Badge>();
          return TabBarView(
            controller: _tabController,
            children: _categories.map((category) {
              return _buildCategoryBadgeView(context, category, badgeModels);
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラー: $error'),
        ),
      ),
    );
  }

  Widget _buildCategoryBadgeView(
    BuildContext context,
    String category,
    List<models.Badge> allBadges,
  ) {
    final theme = Theme.of(context);
    final categoryBadges = allBadges
        .where((badge) => badge.category == category)
        .toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));

    // 獲得日をマップ
    final Map<DateTime, List<models.Badge>> badgesByDate = {};
    for (final badge in categoryBadges) {
      if (badge.isEarned && badge.earnedDate != null) {
        final date = DateTime(
          badge.earnedDate!.year,
          badge.earnedDate!.month,
          badge.earnedDate!.day,
        );
        badgesByDate.putIfAbsent(date, () => []).add(badge);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カレンダー表示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
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
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              eventLoader: (day) {
                return badgesByDate[day] ?? [];
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
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

          const SizedBox(height: 24),

          // バッジグリッド
          Text(
            '${AsyncCategoryService.getCategoryName(category)}のバッジ',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: categoryBadges.length,
            itemBuilder: (context, index) {
              final badge = categoryBadges[index];
              return _buildBadgeCard(context, badge);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BuildContext context, models.Badge badge) {
    final theme = Theme.of(context);
    final themeType = ref.watch(themeTypeProvider);
    final themeStyle = ThemeManager.getThemeStyle(themeType);
    final icon = BadgeService.getBadgeIcon(badge.category, badge.rank);
    final color = BadgeService.getBadgeColor(
      badge.category,
      badge.rank,
      badge.isEarned,
    );
    final size = BadgeService.getBadgeSize(badge.rank);

    return Container(
      padding: themeStyle.cardPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(themeStyle.cardBorderRadius),
        border: Border.all(
          color: badge.isEarned
              ? color
              : theme.colorScheme.outline.withOpacity(0.3),
          width: badge.isEarned ? 2 : 1,
        ),
        boxShadow: badge.isEarned
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: size,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            badge.rankName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: badge.isEarned
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (badge.isEarned && badge.earnedDate != null) ...[
            const SizedBox(height: 4),
            Text(
              DateFormat('yyyy/MM/dd').format(badge.earnedDate!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
