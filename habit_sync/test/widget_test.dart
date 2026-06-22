import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_sync/data/repositories/habit_repository.dart';
import 'package:habit_sync/ui/core/theme/theme_provider.dart';
import 'package:habit_sync/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HabitSync app boots up successfully smoke test', (WidgetTester tester) async {
    // Initialize repository
    final habitRepo = HabitRepository();
    await habitRepo.loadHabits();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<HabitRepository>.value(value: habitRepo),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Trigger frame build
    await tester.pumpAndSettle();

    // Verify HabitSync is displayed
    expect(find.text('HabitSync'), findsOneWidget);
    
    // Verify default habits exist on dashboard
    expect(find.text('Morning Exercise'), findsOneWidget);
    expect(find.text('Read 20 Minutes'), findsOneWidget);
  });
}
