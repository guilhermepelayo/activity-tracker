import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/activity.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Activity> activities;

  AnalyticsScreen({required this.activities});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Activity? selectedActivity;
  String selectedTimeSpan = "Last Week";

  List<String> timeSpans = ["Last Week", "Last Month", "Last Year"];

List<BarChartGroupData> _generateChartData() {
  if (selectedActivity == null) return [];

  final timeEntries = selectedActivity!.timeEntries;
  DateTime now = DateTime.now();
  DateTime filterDate;

  // Filter data based on selected time span
  switch (selectedTimeSpan) {
    case "Last Month":
      filterDate = DateTime(now.year, now.month - 1, now.day);
      break;
    case "Last Year":
      filterDate = DateTime(now.year - 1, now.month, now.day);
      break;
    default:
      filterDate = now.subtract(Duration(days: 7));
  }

  // Filter entries and prepare data
  final filteredEntries = timeEntries
      .where((entry) => entry.date.isAfter(filterDate))
      .toList();

  return filteredEntries.map((entry) {
    return BarChartGroupData(
      x: entry.date.day,
      barRods: [
        BarChartRodData(
          toY: entry.hours, // Update here to use `toY`
          color: Colors.blue,
        ),
      ],
    );
  }).toList();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analytics"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<Activity>(
              hint: Text("Select Activity"),
              value: selectedActivity,
              onChanged: (Activity? newValue) {
                setState(() {
                  selectedActivity = newValue;
                });
              },
              items: widget.activities.map((Activity activity) {
                return DropdownMenuItem<Activity>(
                  value: activity,
                  child: Text(activity.name),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              hint: Text("Select Time Span"),
              value: selectedTimeSpan,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTimeSpan = newValue!;
                });
              },
              items: timeSpans.map((String span) {
                return DropdownMenuItem<String>(
                  value: span,
                  child: Text(span),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: selectedActivity == null
                  ? Center(child: Text("Please select an activity"))
                  : BarChart(
                      BarChartData(
                        barGroups: _generateChartData(),
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
