import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import '../models/activity.dart';
import '../widgets/add_activity_dialog.dart';
import '../widgets/add_time_entry_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Activity> activities = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _saveData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/activities.json');
      final jsonData = jsonEncode(activities.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonData);
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  Future<void> _loadData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/activities.json');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final List<dynamic> data = jsonDecode(jsonData);
        setState(() {
          activities = data.map((e) => Activity.fromJson(e)).toList();
        });
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  void _addActivity(String name, String type) {
    setState(() {
      activities.add(Activity(name: name, type: type, timestamp: DateTime.now()));
    });
    _saveData();
  }

  Future<void> _showAddActivityDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) => AddActivityDialog(["Work", "Exercise", "Study", "Leisure", "Sleep", "Other"]),
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
      _saveData();
    }
  }

  Future<void> _exportData() async {
    try {
      // Generate CSV data
      List<List<String>> csvData = [
        ["Activity Name", "Type", "Time Entry Date", "Hours"]
      ];

      for (var activity in activities) {
        for (var entry in activity.timeEntries) {
          csvData.add([
            activity.name,
            activity.type,
            entry.date.toIso8601String(),
            entry.hours.toString(),
          ]);
        }
      }

      // Save CSV to file
      String csv = const ListToCsvConverter().convert(csvData);
      final directory = await getExternalStorageDirectory();
      final filePath = "${directory!.path}/activity_log.csv";
      final file = File(filePath);
      await file.writeAsString(csv);

      // Share file
      await Share.shareXFiles([XFile(file.path)], text: 'Here is my activity log in CSV format.');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to export data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _exportData,
          ),
        ],
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
