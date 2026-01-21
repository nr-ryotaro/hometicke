import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/done_item.dart';
import '../theme/theme_manager.dart';

class AILetterService {
  // 開発段階では環境変数や設定ファイルから取得することを推奨
  static const String _apiKey = 'YOUR_OPENAI_API_KEY'; // 実際の実装では環境変数から取得
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// AIレターを生成
  static Future<String> generateLetter(
    List<DoneItem> doneList,
    ThemeType themeType,
  ) async {
    // 開発段階: ダミーデータを返す
    if (_apiKey == 'YOUR_OPENAI_API_KEY') {
      return _generateDummyLetter(doneList, themeType);
    }

    try {
      // 実際のAPI呼び出し
      final prompt = _buildPrompt(doneList);
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'あなたは温かく励ます手紙を書くアシスタントです。ユーザーの努力を認め、多才さや努力のバランスを称賛する手紙を書いてください。',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        // APIエラー時はダミーデータを返す
        return _generateDummyLetter(doneList, themeType);
      }
    } catch (e) {
      // エラー時はダミーデータを返す
      return _generateDummyLetter(doneList, themeType);
    }
  }

  /// プロンプトを構築
  static String _buildPrompt(List<DoneItem> doneList) {
    if (doneList.isEmpty) {
      return '今日はDoneがありませんでした。';
    }

    final doneTexts = doneList.map((item) => item.text).join('\n');
    return '''以下のDoneリストから、ユーザーの「多才さ」や「努力のバランス」を見抜き、温かい手紙形式で出力してください。

Doneリスト:
$doneTexts

手紙は日本語で、親しみやすく励ますようなトーンで書いてください。''';
  }

  /// ダミーレターを生成（開発段階用）
  static String _generateDummyLetter(
    List<DoneItem> doneList,
    ThemeType themeType,
  ) {
    if (doneList.isEmpty) {
      return '今日はお疲れ様でした。\n\n明日も素晴らしい一日になりますように。';
    }

    final categories = doneList.map((item) => item.category).toSet();
    final categoryCount = categories.length;
    final totalCount = doneList.length;

    final categoryNames = categories.map((cat) {
      switch (cat) {
        case 'Work':
          return '仕事';
        case 'Growth':
          return '成長';
        case 'Hobby':
          return '趣味';
        case 'Health':
          return '健康';
        case 'Life':
          return '生活';
        default:
          return 'その他';
      }
    }).join('、');

    final themes = [
      '今日も$totalCount個のDoneを達成しましたね！',
      '$categoryCountつの異なる分野（$categoryNames）で活動されたのは素晴らしいです。',
      'バランスの取れた努力が感じられます。',
      'この調子で続けていけば、きっと素晴らしい成果が得られるでしょう。',
      '明日も頑張ってください！応援しています。',
    ];

    return themes.join('\n\n');
  }

  /// レターを表示すべきか判定
  static bool shouldShowLetter(DateTime? lastShownDate, int todayDoneCount) {
    // 0件の日は作成しない
    if (todayDoneCount == 0) return false;

    // 今日既に表示済みかチェック
    if (lastShownDate != null) {
      final now = DateTime.now();
      final lastShown = DateTime(
        lastShownDate.year,
        lastShownDate.month,
        lastShownDate.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      if (lastShown.isAtSameMomentAs(today)) {
        return false;
      }
    }

    return true;
  }
}
