import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import '../providers/done_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/letter_provider.dart';
import '../utils/praise_messages.dart';
import '../theme/app_theme.dart';
import '../theme/theme_manager.dart';
import '../services/category_service.dart';
import '../widgets/letter_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 1),
  );
  final ConfettiController _superConfettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );
  late AnimationController _flashController;
  late AnimationController _praiseBubbleController;
  late Animation<double> _praiseScaleAnimation;
  late Animation<double> _praiseOpacityAnimation;
  late Animation<Offset> _praiseSlideAnimation;
  bool _isFlashing = false;
  String? _lastInputText;
  bool _showInputPopup = false;
  String? _currentPraise;
  bool _showPraiseBubble = false;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _praiseBubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _praiseScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _praiseBubbleController,
        curve: Curves.elasticOut,
      ),
    );
    _praiseOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _praiseBubbleController,
        curve: Curves.easeOut,
      ),
    );
    _praiseSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _praiseBubbleController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _confettiController.dispose();
    _superConfettiController.dispose();
    _flashController.dispose();
    _praiseBubbleController.dispose();
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

    // 褒め言葉を吹き出しで表示
    final praise = PraiseMessages.getRandomPraise();
    if (mounted) {
      setState(() {
        _currentPraise = praise;
        _showPraiseBubble = true;
      });
      _praiseBubbleController.forward();
      
      // 2.5秒後に自動的に消す
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          _praiseBubbleController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showPraiseBubble = false;
                _currentPraise = null;
              });
            }
          });
        }
      });
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

  /// レターをチェックして表示
  Future<void> _checkAndShowLetter(BuildContext context) async {
    try {
      final letterController = ref.read(letterControllerProvider);
      if (letterController.shouldShowLetter()) {
        final letterContent = await letterController.generateTodayLetter();
        if (mounted && letterContent.isNotEmpty) {
          await letterController.markLetterAsShown();
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => LetterDialog(letterContent: letterContent),
          );
        }
      }
    } catch (e) {
      // エラーハンドリング
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayCount = ref.watch(todayDoneCountProvider);
    final todayList = ref.watch(todayDoneListProvider);

    // アプリ起動時にレターをチェック
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowLetter(context);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _flashController,
        builder: (context, child) {
          final theme = Theme.of(context);
          final flashColor = _isFlashing
              ? (_flashController.value < 0.5
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary)
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
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (todayCount > 0)
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: theme.colorScheme.onSurfaceVariant,
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
                              style: theme.textTheme.displayLarge?.copyWith(
                                color: theme.colorScheme.primary,
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '今日のDoneを記録しよう！',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
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
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        child: Icon(
                                          Icons.check,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
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
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            onPressed: () => _showCategoryDialog(
                                              context,
                                              ref,
                                              item.id,
                                              item.category,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
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
                        Builder(
                          builder: (context) {
                            final theme = Theme.of(context);
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _lastInputText!,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
                              enableIMEPersonalizedLearning: true,
                              maxLines: null,
                              minLines: 1,
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
                Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirection: pi / 2,
                        maxBlastForce: 5,
                        minBlastForce: 2,
                        emissionFrequency: 0.05,
                        numberOfParticles: 20,
                        gravity: 0.1,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    );
                  },
                ),

                // スーパー紙吹雪
                Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _superConfettiController,
                        blastDirection: pi / 2,
                        maxBlastForce: 10,
                        minBlastForce: 5,
                        emissionFrequency: 0.1,
                        numberOfParticles: 50,
                        gravity: 0.1,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    );
                  },
                ),
                
                // 褒め言葉の吹き出し
                if (_showPraiseBubble && _currentPraise != null)
                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      return Positioned(
                        bottom: 200,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SlideTransition(
                            position: _praiseSlideAnimation,
                            child: FadeTransition(
                              opacity: _praiseOpacityAnimation,
                              child: ScaleTransition(
                                scale: _praiseScaleAnimation,
                                child: _PraiseBubble(
                                  praise: _currentPraise!,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

// 褒め言葉の吹き出し
class _PraiseBubble extends StatelessWidget {
  final String praise;
  final Color color;

  const _PraiseBubble({
    required this.praise,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      painter: _BubblePainter(color: color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Text(
          praise,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// 吹き出しの形状を描画
class _BubblePainter extends CustomPainter {
  final Color color;

  _BubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // 吹き出しの本体（角丸四角形）
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 12),
      const Radius.circular(20),
    );

    // 影を描画
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.width, size.height - 12),
        const Radius.circular(20),
      ),
      shadowPaint,
    );

    // 本体を描画
    canvas.drawRRect(rect, paint);

    // 三角形のしっぽを描画（下中央）
    final path = Path();
    final tailX = size.width / 2;
    final tailY = size.height - 12;
    path.moveTo(tailX - 12, tailY);
    path.lineTo(tailX, tailY + 12);
    path.lineTo(tailX + 12, tailY);
    path.close();

    // 影のしっぽ
    final shadowPath = Path();
    shadowPath.moveTo(tailX - 12 + 2, tailY + 2);
    shadowPath.lineTo(tailX + 2, tailY + 12 + 2);
    shadowPath.lineTo(tailX + 12 + 2, tailY + 2);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);

    // しっぽを描画
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
