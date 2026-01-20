import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_screen.dart';
import 'theme/theme_manager.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 日本語ロケールの初期化
  await initializeDateFormatting('ja', null);
  // テーマの読み込み
  await ThemeManager.loadTheme();
  
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
