import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import '../providers/done_provider.dart';
import '../utils/praise_messages.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 1),
  );
  final ConfettiController _superConfettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );
  late AnimationController _flashController;
  bool _isFlashing = false;

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

    // Doneを追加
    await ref.read(doneControllerProvider).addDone(text);
    _textController.clear();

    // 褒め言葉を表示
    final praise = PraiseMessages.getRandomPraise();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            praise,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.baseWhite,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppTheme.accentOrange,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.baseWhite,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
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
                                      subtitle: Text(
                                        DateFormat('HH:mm')
                                            .format(item.createdAt),
                                        style: TextStyle(
                                          color: AppTheme.darkGray,
                                          fontSize: 12,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        color: AppTheme.darkGray,
                                        onPressed: () {
                                          ref
                                              .read(doneControllerProvider)
                                              .deleteDone(item.id);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // 下部：入力欄とボタン
                      Container(
                        padding: const EdgeInsets.all(16),
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
                            TextField(
                              controller: _textController,
                              decoration: const InputDecoration(
                                hintText: 'やったことを入力...',
                                prefixIcon: Icon(Icons.edit),
                              ),
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
}
