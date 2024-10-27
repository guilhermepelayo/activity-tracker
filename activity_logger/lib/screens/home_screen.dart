import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../widgets/add_activity_dialog.dart';
import '../widgets/add_time_entry_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Activity> activities = [];

  // Default activity types
  final List<String> defaultActivityTypes = [
    "Work",
    "Exercise",
    "Study",
    "Leisure",
    "Sleep",
    "Other"
  ];

  void _addActivity(String name, String type) {
    setState(() {
      activities.add(Activity(name: name, type: type, timestamp: DateTime.now()));
    });
  }

  Future<void> _showAddActivityDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) => AddActivityDialog(defaultActivityTypes),
    );
    if (result != null) {
      _addActivity(result["name"]!, result["type"]!);
    }
  }

  Future<void> _showAddTimeEntryDialog(Activity activity) async {
    final timeEntry = await showDialog<TimeEntry>(
      context: context,
      builder: (BuildContext context) => AddTimeEntryDialog(),
    );
    if (timeEntry != null) {
      setState(() {
        activity.timeEntries.add(timeEntry);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Tracker'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  title: Text(activity.name),
                  subtitle: Text(activity.type),
                  onTap: () => _showAddTimeEntryDialog(activity),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddActivityDialog,
              child: Text('Add Activity'),
            ),
          ),
        ],
      ),
    );
  }
}
