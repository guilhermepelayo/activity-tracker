import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(ActivityLoggerApp());
}

class ActivityLoggerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Logger',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system, // Uses system setting for light/dark mode
      home: HomeScreen(),
    );
  }
}
