// Smoke tests for the app's colour/theme tokens.
//
// Two things are deliberately NOT covered here:
//
//  * TbnApp itself cannot be pumped: it depends on dotenv being loaded and the
//    GetIt service locator being populated, both of which happen in main()
//    before runApp.
//  * AppTheme.darkTheme / AppTypography cannot be exercised in tests while
//    typography is sourced from google_fonts, which fetches Manrope and Inter
//    over HTTP at runtime and throws in a sandboxed test environment. Once the
//    fonts are bundled as local assets, theme-level tests belong here too.
//
// What is covered is the colour layer, which is pure and dependency-free.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tbn_lms/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('dark scheme is a coherent dark surface/on-surface pairing', () {
      const scheme = AppColors.darkScheme;

      expect(scheme.brightness, Brightness.dark);
      expect(scheme.primary, AppColors.primary);
      expect(scheme.surface.computeLuminance(),
          lessThan(scheme.onSurface.computeLuminance()));
    });

    test('body text meets WCAG AA contrast against the app background', () {
      double contrast(Color a, Color b) {
        final l1 = a.computeLuminance();
        final l2 = b.computeLuminance();
        final hi = l1 > l2 ? l1 : l2;
        final lo = l1 > l2 ? l2 : l1;
        return (hi + 0.05) / (lo + 0.05);
      }

      // Primary and secondary text must stay readable on both the base
      // background and the raised card surface.
      expect(contrast(AppColors.textPrimary, AppColors.background),
          greaterThanOrEqualTo(4.5));
      expect(contrast(AppColors.textSecondary, AppColors.background),
          greaterThanOrEqualTo(4.5));
      expect(contrast(AppColors.textPrimary, AppColors.cardSurface),
          greaterThanOrEqualTo(4.5));
    });

    test('surface tokens referenced across the UI are all defined', () {
      // These four were missing and broke the build; keep them pinned.
      expect(AppColors.surfaceDim, isA<Color>());
      expect(AppColors.surfaceVariant, isA<Color>());
      expect(AppColors.border, isA<Color>());
      expect(AppColors.info, isA<Color>());
    });
  });

  testWidgets('dark colour scheme flows through a MaterialApp', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.from(colorScheme: AppColors.darkScheme),
        home: const Scaffold(body: Center(child: Text('TBN LMS'))),
      ),
    );

    expect(find.text('TBN LMS'), findsOneWidget);

    final context = tester.element(find.text('TBN LMS'));
    expect(Theme.of(context).colorScheme.primary, AppColors.primary);
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
