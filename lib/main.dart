import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:havit_tracker/core/theme data/dark_theme.dart';
import 'package:havit_tracker/core/theme data/light_theme.dart';
import 'package:havit_tracker/features/home/presentation/bloc/habits_bloc.dart';
import 'package:havit_tracker/features/home/presentation/pages/home_screen.dart';

// Global theme notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  runApp(
    BlocProvider(
      create: (_) => HabitsBloc(secureStorage)..add(FeatchHabitsEvent()),
      child: MyApp(themeNotifier: themeNotifier),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const MyApp({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          title: 'Havit Tracker',
          themeMode: currentTheme,
          theme: lightTheme,
          darkTheme: darkTheme,
          debugShowCheckedModeBanner: false,
          home: HomeScreen(themeNotifier: themeNotifier),
        );
      },
    );
  }
}
