import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme_manager.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LetterDialog extends ConsumerWidget {
  final String letterContent;

  const LetterDialog({
    super.key,
    required this.letterContent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeTypeProvider);
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _getPaperColor(themeType),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 便箋のヘッダー
            _buildLetterHeader(context, themeType),
            const SizedBox(height: 24),
            // レター本文
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  letterContent,
                  style: _getTextStyle(themeType, theme),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 閉じるボタン
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '閉じる',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterHeader(BuildContext context, ThemeType themeType) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.mail_outline,
          color: _getAccentColor(themeType),
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          '本日の総評',
          style: _getHeaderStyle(themeType, theme),
        ),
      ],
    );
  }

  Color _getPaperColor(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.pop:
        return const Color(0xFFFFF8E1); // 薄いオレンジ
      case ThemeType.elegant:
        return const Color(0xFFF5F5DC); // ベージュ
      case ThemeType.formal:
        return Colors.white;
      case ThemeType.simple:
        return Colors.white;
    }
  }

  Color _getAccentColor(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.pop:
        return const Color(0xFFFF9800);
      case ThemeType.elegant:
        return const Color(0xFF1E3A5F);
      case ThemeType.formal:
        return const Color(0xFF37474F);
      case ThemeType.simple:
        return Colors.black;
    }
  }

  TextStyle _getHeaderStyle(ThemeType themeType, ThemeData theme) {
    switch (themeType) {
      case ThemeType.pop:
        return GoogleFonts.bungee(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: _getAccentColor(themeType),
        );
      case ThemeType.elegant:
        return GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: _getAccentColor(themeType),
        );
      case ThemeType.formal:
        return GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _getAccentColor(themeType),
        );
      case ThemeType.simple:
        return GoogleFonts.mPlus1p(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: _getAccentColor(themeType),
        );
    }
  }

  TextStyle _getTextStyle(ThemeType themeType, ThemeData theme) {
    final baseStyle = TextStyle(
      fontSize: 16,
      height: 1.8,
      color: theme.colorScheme.onSurface,
    );

    switch (themeType) {
      case ThemeType.pop:
        return baseStyle.copyWith(fontFamily: GoogleFonts.bungee().fontFamily);
      case ThemeType.elegant:
        return baseStyle.copyWith(fontFamily: GoogleFonts.playfairDisplay().fontFamily);
      case ThemeType.formal:
        return baseStyle.copyWith(fontFamily: GoogleFonts.inter().fontFamily);
      case ThemeType.simple:
        return baseStyle.copyWith(fontFamily: GoogleFonts.mPlus1p().fontFamily);
    }
  }
}
