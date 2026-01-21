import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/main_screen.dart';
import 'theme/theme_manager.dart';
import 'providers/theme_provider.dart';
import 'models/badge.dart';
import 'models/letter_settings.dart';
import 'models/done_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 日本語ロケールの初期化
  await initializeDateFormatting('ja', null);
  // テーマの読み込み
  await ThemeManager.loadTheme();
  // Hive初期化（一度だけ実行）
  await Hive.initFlutter();
  // アダプター登録（すべてのモデルを登録）
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(DoneItemAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(BadgeAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(LetterSettingsAdapter());
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeTypeProvider);
    
    return MaterialApp(
      title: 'Hometicke - Done褒めカウンター',
      theme: ThemeManager.getTheme(themeType),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
