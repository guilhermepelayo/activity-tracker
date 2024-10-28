import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Activity> activities;

  const AnalyticsScreen({super.key, required this.activities});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Activity? selectedActivity;
  String selectedTimeSpan = "This Week";
  DateTime? startDate;
  DateTime? endDate;
  Map<String, double> groupedData = {};

Future<void> _selectDateRange(BuildContext context) async {
  final DateTime now = DateTime.now();
  final pickedRange = await showDateRangePicker(
    context: context,
    initialDateRange: (startDate != null && endDate != null)
        ? DateTimeRange(start: startDate!, end: endDate!)
        : DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
    firstDate: DateTime(2000),
    lastDate: DateTime(now.year + 10), // Extends the range for future selection
    locale: const Locale('en', 'GB'),
  );

  if (pickedRange != null) {
    setState(() {
      startDate = pickedRange.start;
      endDate = pickedRange.end;
    });
  }
}


  List<Map<String, dynamic>> _generateTableData() {
    List<Map<String, dynamic>> tableData = [];

    if (selectedActivity == null || startDate == null || endDate == null) {
      return tableData;
    }

    tableData = selectedActivity!.timeEntries
        .where((entry) =>
            entry.date.isAfter(startDate!.subtract(Duration(days: 1))) &&
            entry.date.isBefore(endDate!.add(Duration(days: 1))))
        .map((entry) => {
              "Date": DateFormat('dd/MM/yyyy').format(entry.date),
              "Hours": entry.hours,
            })
        .toList();

    return tableData;
  }

  List<BarChartGroupData> _generateWeekChartData() {
    groupedData.clear();
    if (selectedActivity == null) return [];

    DateTime now = DateTime.now();
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

    int x = 0;
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
                  if (selectedTimeSpan == "This Week") {
                    startDate = null;
                    endDate = null;
                  } else if (selectedTimeSpan == "Select Date Range") {
                    _selectDateRange(context);
                  }
                });
              },
              items: [
                "This Week",
                "Select Date Range",
              ].map((String span) {
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
                  : selectedTimeSpan == "This Week"
                      ? BarChart(
                          BarChartData(
                            barGroups: _generateWeekChartData(),
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
                                    if (value.toInt() <
                                        groupedData.keys.length) {
                                      final dateKey = groupedData.keys
                                          .elementAt(value.toInt());
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
                        )
                      : ListView(
                          children: _generateTableData().map((data) {
                            return ListTile(
                              title: Text("Date: ${data['Date']}"),
                              subtitle: Text("Hours: ${data['Hours']}"),
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
