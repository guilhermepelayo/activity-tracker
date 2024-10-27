import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(ActivityLoggerApp());
}

class ActivityLoggerApp extends StatelessWidget {
  const ActivityLoggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Logger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
