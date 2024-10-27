class Activity {
  String name;
  String type;
  DateTime timestamp;
  List<TimeEntry> timeEntries;

  Activity({
    required this.name,
    required this.type,
    required this.timestamp,
    this.timeEntries = const [],
  });

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
        timeEntries: (json['timeEntries'] as List<dynamic>)
            .map((e) => TimeEntry.fromJson(e as Map<String, dynamic>))
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
