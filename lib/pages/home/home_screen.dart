import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
    final ValueNotifier<ThemeMode> themeNotifier;

  const HomeScreen({super.key, required this.themeNotifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer( 
        backgroundColor: Theme.of(context).colorScheme.background,
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: widget.themeNotifier,
          builder: (context, mode, _) {
            final isDarkMode = mode == ThemeMode.dark;
            return Center( 
              child: CupertinoSwitch(
                value: isDarkMode,
                onChanged: (value) {
                  widget.themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Text(
          'Home Screen',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}