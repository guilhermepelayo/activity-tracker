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
    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateTime(DateTime.now().year, DateTime.now().month, 1),
        end: DateTime.now(),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('en', 'GB'),
    );

    if (pickedRange != null) {
      setState(() {
        startDate = pickedRange.start;
        endDate = pickedRange.end;
      });
    }
  }

  Future<void> _selectSingleDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('en', 'GB'),
    );

    if (pickedDate != null) {
      setState(() {
        startDate = pickedDate;
        endDate = pickedDate;
      });
    }
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year, now.month, 1),
      firstDate: DateTime(2000),
      lastDate:
          DateTime(now.year + 1, 12, 31), // Last day of the following year
      initialDatePickerMode: DatePickerMode.year,
      locale: const Locale('en', 'GB'),
    );

    if (pickedDate != null) {
      setState(() {
        startDate = DateTime(pickedDate.year, pickedDate.month, 1);
        endDate =
            DateTime(pickedDate.year, pickedDate.month + 1, 0); // End of month
      });
    }
  }

  List<Map<String, dynamic>> _generateTableData() {
    // Ensure `tableData` is cleared each time this function runs
    List<Map<String, dynamic>> tableData = [];

    // Return empty data if no activity or dates are set
    if (selectedActivity == null || startDate == null || endDate == null) {
      return tableData;
    }

    // Populate table data if entries fall within the selected date range
    tableData = selectedActivity!.timeEntries
        .where((entry) =>
            entry.date.isAfter(startDate!.subtract(Duration(days: 1))) &&
            entry.date.isBefore(endDate!.add(Duration(days: 1))))
        .map((entry) => {
              "Date": DateFormat('dd/MM/yyyy').format(entry.date),
              "Hours": entry.hours,
            })
        .toList();

    return tableData; // This will return an empty list if no entries match the selected date range
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
                  } else if (selectedTimeSpan == "Select Single Date") {
                    _selectSingleDate(context);
                  } else if (selectedTimeSpan == "Select Month and Year") {
                    _selectMonthYear(context);
                  }
                });
              },
              items: [
                "This Week",
                "Select Date Range",
                "Select Single Date",
                "Select Month and Year",
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
