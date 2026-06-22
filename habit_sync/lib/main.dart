import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/habit_repository.dart';
import 'router.dart';
import 'ui/core/theme/theme.dart';
import 'ui/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup logic repository
  final habitRepo = HabitRepository();
  await habitRepo.loadHabits();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<HabitRepository>.value(value: habitRepo),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'HabitSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: appRouter,
    );
  }
}
