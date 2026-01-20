import 'dart:async';

/// カテゴリー定義
class Category {
  static const String work = 'Work';
  static const String growth = 'Growth';
  static const String hobby = 'Hobby';
  static const String health = 'Health';
  static const String life = 'Life';
  static const String uncategorized = 'Uncategorized';
}

/// カテゴリー分類サービス
class AsyncCategoryService {
  // カテゴリー別キーワードリスト
  static final Map<String, List<String>> _keywords = {
    Category.work: [
      'IT', '金融', '会議', '資料作成', '昇格', 'プロジェクト', '営業', '企画',
      'プレゼン', '報告', '打ち合わせ', 'ミーティング', '会議', '資料', '提案',
      '契約', '商談', '顧客', 'クライアント', '業務', '仕事', '出社', '退社',
    ],
    Category.growth: [
      'AWS', 'SAA', 'PMP', 'TOEIC', 'プログラミング', '資格', '勉強', '学習',
      '読書', 'セミナー', '研修', 'トレーニング', '講座', 'スクール', '教育',
      'スキル', '技術', '知識', '習得', '向上', '開発', 'コード', 'アプリ',
    ],
    Category.hobby: [
      'バンド', '樂園', 'ドラム', 'カメラ', 'ライカ', '動画編集', 'バイク',
      'ドゥカティ', 'サッカー', '音楽', '楽器', '演奏', '撮影', '写真',
      '映画', 'ゲーム', '旅行', 'アウトドア', 'スポーツ', '趣味', '創作',
    ],
    Category.health: [
      'ランニング', '筋トレ', 'ジョギング', '健康', '運動', 'トレーニング',
      'ウォーキング', 'ヨガ', 'ストレッチ', 'ダイエット', '食事', '栄養',
      '睡眠', 'メンタル', '体調', 'フィットネス', 'ジム', 'マラソン',
    ],
    Category.life: [
      '洗濯', '掃除', '料理', '猫', 'お世話', '家計', 'パートナー', '家族',
      '買い物', '家事', '片付け', '整理', '清掃', '食事', '準備', '計画',
      '予約', '手続き', '管理', 'メンテナンス', '修理', '改善',
    ],
  };

  /// キーワードベースの高速判定
  static String? _classifyByKeywords(String text) {
    final lowerText = text.toLowerCase();
    
    // 各カテゴリーのキーワードをチェック
    for (final entry in _keywords.entries) {
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }
    
    return null;
  }

  /// カテゴリー分類を実行（非同期）
  /// まずキーワード判定を試み、判定不能な場合のみAI判定を呼び出す
  static Future<String> classifyAsync(String text) async {
    // 即座にキーワード判定を試みる
    final keywordResult = _classifyByKeywords(text);
    if (keywordResult != null) {
      return keywordResult;
    }

    // キーワード判定で分類できない場合、AI判定をバックグラウンドで実行
    // 注意: 実際のAI API呼び出しは実装が必要（現在はフォールバック）
    return await _classifyByAI(text);
  }

  /// AI判定（gpt-4o-miniを使用）
  /// 注意: 実際の実装ではOpenAI APIやその他のAIサービスを使用
  static Future<String> _classifyByAI(String text) async {
    // TODO: 実際のAI API呼び出しを実装
    // 現在は簡易的なフォールバック処理
    await Future.delayed(const Duration(milliseconds: 500));
    
    // フォールバック: テキストの長さや特徴から推測
    // 実際の実装では、OpenAI APIなどを呼び出す
    return Category.uncategorized;
  }

  /// カテゴリーの日本語名を取得
  static String getCategoryName(String category) {
    switch (category) {
      case Category.work:
        return '仕事';
      case Category.growth:
        return '成長';
      case Category.hobby:
        return '趣味';
      case Category.health:
        return '健康';
      case Category.life:
        return '生活';
      default:
        return '未分類';
    }
  }

  /// カテゴリーの色を取得（UI用）
  static int getCategoryColor(String category) {
    switch (category) {
      case Category.work:
        return 0xFF1E3A5F; // ネイビー
      case Category.growth:
        return 0xFFFF9800; // オレンジ
      case Category.hobby:
        return 0xFF03A9F4; // ライトブルー（元の色）
      case Category.health:
        return 0xFF4CAF50; // グリーン
      case Category.life:
        return 0xFF9C27B0; // パープル
      default:
        return 0xFF757575; // グレー
    }
  }
}
