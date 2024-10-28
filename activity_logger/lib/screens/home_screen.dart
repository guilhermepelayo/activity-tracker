import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../screens/analytics_screen.dart';
import '../widgets/add_activity_dialog.dart';

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

      String csv = const ListToCsvConverter().convert(csvData);
      final directory = await getExternalStorageDirectory();
      final filePath = "${directory!.path}/activity_log.csv";
      final file = File(filePath);
      await file.writeAsString(csv);

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
            icon: Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyticsScreen(activities: activities),
                ),
              );
            },
          ),
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

class AddTimeEntryDialog extends StatefulWidget {
  @override
  _AddTimeEntryDialogState createState() => _AddTimeEntryDialogState();
}

class _AddTimeEntryDialogState extends State<AddTimeEntryDialog> {
  DateTime? startTime;
  DateTime? endTime;
  double? hours;
  bool useHoursEntry = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Time Entry"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: Text("Enter by hours"),
            value: useHoursEntry,
            onChanged: (value) {
              setState(() {
                useHoursEntry = value;
              });
            },
          ),
          useHoursEntry
              ? TextField(
                  decoration: InputDecoration(labelText: "Hours"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    hours = double.tryParse(value);
                  },
                )
              : Column(
                  children: [
                    ListTile(
                      title: Text("Start Time"),
                      subtitle: Text(startTime == null
                          ? "Not set"
                          : DateFormat('HH:mm').format(startTime!)),
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            startTime = DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text("End Time"),
                      subtitle: Text(endTime == null
                          ? "Not set"
                          : DateFormat('HH:mm').format(endTime!)),
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            endTime = DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (useHoursEntry && hours != null) {
              Navigator.pop(context, TimeEntry(date: DateTime.now(), hours: hours!));
            } else if (startTime != null && endTime != null) {
              final duration = endTime!.difference(startTime!).inHours.toDouble();
              Navigator.pop(context, TimeEntry(date: DateTime.now(), hours: duration));
            }
          },
          child: Text("Add"),
        ),
      ],
    );
  }
}
