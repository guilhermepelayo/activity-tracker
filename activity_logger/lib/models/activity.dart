class Activity {
  final String name;
  final String type;
  final DateTime timestamp;
  List<TimeEntry> timeEntries;

  Activity({
    required this.name,
    required this.type,
    required this.timestamp,
    List<TimeEntry>? timeEntries,
  }) : timeEntries = timeEntries ?? []; // Initializes timeEntries as an empty list if null

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'timeEntries': timeEntries.map((e) => e.toJson()).toList(),
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        name: json['name'],
        type: json['type'],
        timestamp: DateTime.parse(json['timestamp']),
        timeEntries: (json['timeEntries'] as List)
            .map((e) => TimeEntry.fromJson(e))
            .toList(),
      );
}


class TimeEntry {
  DateTime date;
  double hours;

  TimeEntry({
    required this.date,
    required this.hours,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'hours': hours,
      };

  factory TimeEntry.fromJson(Map<String, dynamic> json) => TimeEntry(
        date: DateTime.parse(json['date']),
        hours: json['hours'],
      );
}
