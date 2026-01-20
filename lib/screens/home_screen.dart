import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import '../providers/done_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/praise_messages.dart';
import '../theme/app_theme.dart';
import '../theme/theme_manager.dart';
import '../services/category_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 1),
  );
  final ConfettiController _superConfettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );
  late AnimationController _flashController;
  bool _isFlashing = false;
  String? _lastInputText;
  bool _showInputPopup = false;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _confettiController.dispose();
    _superConfettiController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  Future<void> _handleDone() async {
    final text = _textController.text;
    if (text.trim().isEmpty) return;

    // 現在のカウントを取得
    final currentCount = ref.read(todayDoneCountProvider);
    final isSuperBonus = currentCount == 9; // 9回目で押したら10回目になる

    // ハプティックフィードバック
    HapticFeedback.lightImpact();

    // 入力内容を保存してポップアップ表示
    setState(() {
      _lastInputText = text;
      _showInputPopup = true;
    });

    // Doneを追加
    await ref.read(doneControllerProvider).addDone(text);
    _textController.clear();

    // 入力欄に自動的にフォーカスを戻す
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _textFocusNode.requestFocus();
      }
    });

    // ポップアップを3秒後に自動的に消す
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showInputPopup = false;
        });
      }
    });

    // 褒め言葉を表示
    final praise = PraiseMessages.getRandomPraise();
    if (mounted) {
      // 褒め言葉をカスタムダイアログ風に表示
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        barrierDismissible: true,
        builder: (context) => _PraiseDialog(praise: praise),
      );
    }

    // 演出
    if (isSuperBonus) {
      _triggerSuperBonus();
    } else {
      _triggerNormalEffect();
    }
  }

  void _triggerNormalEffect() {
    _confettiController.play();
  }

  void _triggerSuperBonus() {
    // フラッシュ演出
    setState(() {
      _isFlashing = true;
    });
    _flashController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _flashController.stop();
        _flashController.reset();
        setState(() {
          _isFlashing = false;
        });
      }
    });

    // スーパー紙吹雪
    _superConfettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final todayCount = ref.watch(todayDoneCountProvider);
    final todayList = ref.watch(todayDoneListProvider);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _flashController,
        builder: (context, child) {
          final flashColor = _isFlashing
              ? (_flashController.value < 0.5
                  ? AppTheme.accentOrange
                  : AppTheme.accentBlue)
              : Colors.transparent;

          return Container(
            color: flashColor.withOpacity(0.3),
            child: Stack(
              children: [
                // メインコンテンツ
                SafeArea(
                  child: Column(
                    children: [
                      // 上部：本日の合計Done数
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
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '本日のDone',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppTheme.darkGray,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                if (todayCount > 0)
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: AppTheme.darkGray,
                                    tooltip: '今日のDoneを一括削除',
                                    onPressed: () => _showDeleteTodayDialog(
                                      context,
                                      ref,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$todayCount',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    color: AppTheme.accentOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 64,
                                  ),
                            ),
                          ],
                        ),
                          );
                        },
                      ),

                      // 中央：履歴リスト
                      Expanded(
                        child: todayList.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 64,
                                      color:
                                          AppTheme.darkGray.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '今日のDoneを記録しよう！',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppTheme.darkGray,
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: todayList.length,
                                itemBuilder: (context, index) {
                                  final item = todayList[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.accentBlue,
                                        child: const Icon(
                                          Icons.check,
                                          color: AppTheme.baseWhite,
                                        ),
                                      ),
                                      title: Text(
                                        item.text,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat('HH:mm')
                                                .format(item.createdAt),
                                            style: TextStyle(
                                              color: AppTheme.darkGray,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          GestureDetector(
                                            onTap: () => _showCategoryDialog(
                                              context,
                                              ref,
                                              item.id,
                                              item.category,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(
                                                  AsyncCategoryService
                                                      .getCategoryColor(
                                                    item.category,
                                                  ),
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Color(
                                                    AsyncCategoryService
                                                        .getCategoryColor(
                                                      item.category,
                                                    ),
                                                  ).withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.label_outline,
                                                    size: 12,
                                                    color: Color(
                                                      AsyncCategoryService
                                                          .getCategoryColor(
                                                        item.category,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    AsyncCategoryService
                                                        .getCategoryName(
                                                      item.category,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Color(
                                                        AsyncCategoryService
                                                            .getCategoryColor(
                                                          item.category,
                                                        ),
                                                      ),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            color: AppTheme.darkGray,
                                            onPressed: () => _showCategoryDialog(
                                              context,
                                              ref,
                                              item.id,
                                              item.category,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            color: AppTheme.darkGray,
                                            onPressed: () {
                                              ref
                                                  .read(doneControllerProvider)
                                                  .deleteDone(item.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // 入力ポップアップ表示
                      if (_showInputPopup && _lastInputText != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.accentOrange.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.accentOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _lastInputText!,
                                  style: TextStyle(
                                    color: AppTheme.textBlack,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 下部：入力欄とボタン
                      Builder(
                        builder: (context) {
                          final themeType = ref.watch(themeTypeProvider);
                          final themeStyle = ThemeManager.getThemeStyle(themeType);
                          final theme = Theme.of(context);
                          
                          return Container(
                            padding: themeStyle.cardPadding,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              boxShadow: themeStyle.useBoldShadows
                                  ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, -8),
                                      ),
                                    ]
                                  : [
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
                            TextField(
                              controller: _textController,
                              focusNode: _textFocusNode,
                              decoration: const InputDecoration(
                                hintText: 'やったことを入力...',
                                prefixIcon: Icon(Icons.edit),
                              ),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              enableSuggestions: true,
                              autocorrect: true,
                              textCapitalization: TextCapitalization.none,
                              onSubmitted: (_) => _handleDone(),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleDone,
                                child: const Text('DONE!'),
                              ),
                            ),
                          ],
                        ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 通常紙吹雪
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: pi / 2,
                    maxBlastForce: 5,
                    minBlastForce: 2,
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    gravity: 0.1,
                    colors: const [
                      AppTheme.accentOrange,
                      AppTheme.accentBlue,
                    ],
                  ),
                ),

                // スーパー紙吹雪
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _superConfettiController,
                    blastDirection: pi / 2,
                    maxBlastForce: 10,
                    minBlastForce: 5,
                    emissionFrequency: 0.1,
                    numberOfParticles: 50,
                    gravity: 0.1,
                    colors: const [
                      AppTheme.accentOrange,
                      AppTheme.accentBlue,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 今日のDone一括削除ダイアログ
  void _showDeleteTodayDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('今日のDoneを一括削除'),
        content: const Text('今日記録したすべてのDoneを削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(doneControllerProvider).deleteTodayDone();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  /// カテゴリー選択ダイアログを表示
  void _showCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    String itemId,
    String currentCategory,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カテゴリーを選択'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCategoryOption(
              context,
              ref,
              itemId,
              Category.work,
              '仕事',
              currentCategory,
            ),
            _buildCategoryOption(
              context,
              ref,
              itemId,
              Category.growth,
              '成長',
              currentCategory,
            ),
            _buildCategoryOption(
              context,
              ref,
              itemId,
              Category.hobby,
              '趣味',
              currentCategory,
            ),
            _buildCategoryOption(
              context,
              ref,
              itemId,
              Category.health,
              '健康',
              currentCategory,
            ),
            _buildCategoryOption(
              context,
              ref,
              itemId,
              Category.life,
              '生活',
              currentCategory,
            ),
            _buildCategoryOption(
              context,
              ref,
              itemId,
              Category.uncategorized,
              '未分類',
              currentCategory,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryOption(
    BuildContext context,
    WidgetRef ref,
    String itemId,
    String category,
    String categoryName,
    String currentCategory,
  ) {
    final isSelected = category == currentCategory;
    final color = Color(AsyncCategoryService.getCategoryColor(category));

    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 16,
                color: AppTheme.baseWhite,
              )
            : null,
      ),
      title: Text(categoryName),
      onTap: () {
        ref.read(doneControllerProvider).updateCategory(itemId, category);
        Navigator.of(context).pop();
      },
    );
  }
}

// 褒め言葉ダイアログ
class _PraiseDialog extends StatelessWidget {
  final String praise;

  const _PraiseDialog({required this.praise});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accentOrange.withOpacity(0.95),
              AppTheme.accentOrange,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentOrange.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ハートアイコン
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.baseWhite.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: AppTheme.baseWhite,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            // 褒め言葉
            Text(
              praise,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.baseWhite,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // 装飾的な線
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.baseWhite.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
