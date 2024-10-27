class Activity {
  final String name;
  final String type;
  final DateTime timestamp;
  final List<TimeEntry> timeEntries = [];

  Activity({required this.name, required this.type, required this.timestamp});
}

class TimeEntry {
  final DateTime date;
  final double hours;

  TimeEntry({required this.date, required this.hours});
}
