import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/activity.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Activity> activities;

  AnalyticsScreen({required this.activities});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Activity? selectedActivity;
  String selectedTimeSpan = "This Week";
  List<String> timeSpans = ["This Week", "Last Month", "Last Year"];
  Map<String, double> groupedData = {};

  List<BarChartGroupData> _generateChartData() {
    groupedData.clear();

    if (selectedActivity == null) return [];

    DateTime now = DateTime.now();

    if (selectedTimeSpan == "This Week") {
      DateTime startOfWeek = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: (now.weekday - DateTime.monday) % 7));
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

      for (int i = 0; i <= 6; i++) {
        DateTime currentDay = startOfWeek.add(Duration(days: i));
        String dayLabel = DateFormat('EEE').format(currentDay);
        groupedData[dayLabel] = 0;
      }

      for (var entry in selectedActivity!.timeEntries) {
        DateTime entryDateOnly =
            DateTime(entry.date.year, entry.date.month, entry.date.day);
        if (!entryDateOnly.isBefore(startOfWeek) &&
            !entryDateOnly.isAfter(endOfWeek)) {
          String dayLabel = DateFormat('EEE').format(entry.date);
          groupedData[dayLabel] = groupedData[dayLabel]! + entry.hours;
        }
      }
    } else if (selectedTimeSpan == "Last Month") {
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      int daysInLastMonth =
          DateTime(startOfMonth.year, startOfMonth.month + 1, 1)
              .subtract(Duration(days: 1))
              .day;

      DateTime weekStart = startOfMonth;
      int weekIndex = 1;

      while (weekStart.month == startOfMonth.month) {
        DateTime weekEnd = weekStart.add(Duration(days: 6));
        if (weekEnd.month != startOfMonth.month) {
          weekEnd =
              DateTime(startOfMonth.year, startOfMonth.month, daysInLastMonth);
        }

        String weekLabel = "Week $weekIndex";
        groupedData[weekLabel] = 0.0;

        print(
            "Checking for entries between ${weekStart.toIso8601String()} and ${weekEnd.toIso8601String()} for $weekLabel");

        for (var entry in selectedActivity!.timeEntries) {
          DateTime entryDateOnly =
              DateTime(entry.date.year, entry.date.month, entry.date.day);
          if (!entryDateOnly.isBefore(weekStart) &&
              !entryDateOnly.isAfter(weekEnd)) {
            groupedData[weekLabel] = groupedData[weekLabel]! + entry.hours;
            print(
                "Added ${entry.hours} hours for entry on ${entry.date.toIso8601String()} to $weekLabel");
          }
        }

        weekIndex++;
        weekStart = weekEnd.add(Duration(days: 1));
      }
    }

    int x = 0;
    print("Final chart data generated: $groupedData");
    return groupedData.entries.map((entry) {
      return BarChartGroupData(
        x: x++,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
          ),
        ],
        showingTooltipIndicators: [0],
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
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < groupedData.keys.length) {
                                  final dateKey =
                                      groupedData.keys.elementAt(value.toInt());
                                  return Text(dateKey);
                                }
                                return Text('');
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
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
