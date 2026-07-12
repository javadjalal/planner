import 'dart:convert';

enum ActivityType { work, study, gym, rest, review, other }

enum DayType { weekday, weekend }

class TimeOfDaySimple {
  final int hour;
  final int minute;

  const TimeOfDaySimple(this.hour, this.minute);

  String format() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Map<String, dynamic> toJson() => {'hour': hour, 'minute': minute};

  factory TimeOfDaySimple.fromJson(Map<String, dynamic> json) =>
      TimeOfDaySimple(json['hour'], json['minute']);

  factory TimeOfDaySimple.fromString(String s) {
    final parts = s.split(':');
    return TimeOfDaySimple(int.parse(parts[0]), int.parse(parts[1]));
  }
}

class Activity {
  final String id;
  String name;
  TimeOfDaySimple startTime;
  TimeOfDaySimple endTime;
  ActivityType type;
  bool alarmEnabled;
  DayType dayType;

  Activity({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.alarmEnabled = true,
    this.dayType = DayType.weekday,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startTime': startTime.toJson(),
        'endTime': endTime.toJson(),
        'type': type.index,
        'alarmEnabled': alarmEnabled,
        'dayType': dayType.index,
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'],
        name: json['name'],
        startTime: TimeOfDaySimple.fromJson(json['startTime']),
        endTime: TimeOfDaySimple.fromJson(json['endTime']),
        type: ActivityType.values[json['type']],
        alarmEnabled: json['alarmEnabled'] ?? true,
        dayType: DayType.values[json['dayType'] ?? 0],
      );

  Activity copyWith({
    String? name,
    TimeOfDaySimple? startTime,
    TimeOfDaySimple? endTime,
    ActivityType? type,
    bool? alarmEnabled,
    DayType? dayType,
  }) =>
      Activity(
        id: id,
        name: name ?? this.name,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        type: type ?? this.type,
        alarmEnabled: alarmEnabled ?? this.alarmEnabled,
        dayType: dayType ?? this.dayType,
      );
}

class DailyRecord {
  final String date;
  final Map<String, bool> completedActivities;
  String note;

  DailyRecord({
    required this.date,
    required this.completedActivities,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'completed': completedActivities,
        'note': note,
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
        date: json['date'],
        completedActivities: Map<String, bool>.from(json['completed'] ?? {}),
        note: json['note'] ?? '',
      );
}

class Challenge {
  final String id;
  final String titleFa;
  final String titleEn;
  final int points;
  bool isCompleted;

  Challenge({
    required this.id,
    required this.titleFa,
    required this.titleEn,
    required this.points,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'completed': isCompleted,
      };
}

class AppState {
  List<Activity> activities;
  Map<String, DailyRecord> records;
  int totalPoints;
  String shortTermGoal;
  String longTermGoal;
  bool isPersian;
  int streakDays;

  AppState({
    required this.activities,
    required this.records,
    this.totalPoints = 0,
    this.shortTermGoal = '',
    this.longTermGoal = '',
    this.isPersian = true,
    this.streakDays = 0,
  });
}

List<Activity> defaultWeekdayActivities() => [
      Activity(
        id: 'wake',
        name: 'بیدار شدن',
        startTime: const TimeOfDaySimple(6, 0),
        endTime: const TimeOfDaySimple(6, 30),
        type: ActivityType.rest,
        dayType: DayType.weekday,
      ),
      Activity(
        id: 'work',
        name: 'اداره',
        startTime: const TimeOfDaySimple(7, 0),
        endTime: const TimeOfDaySimple(13, 0),
        type: ActivityType.work,
        dayType: DayType.weekday,
      ),
      Activity(
        id: 'lunch',
        name: 'ناهار و استراحت',
        startTime: const TimeOfDaySimple(13, 0),
        endTime: const TimeOfDaySimple(14, 0),
        type: ActivityType.rest,
        dayType: DayType.weekday,
      ),
      Activity(
        id: 'study',
        name: 'مطالعه کنکور',
        startTime: const TimeOfDaySimple(14, 0),
        endTime: const TimeOfDaySimple(17, 0),
        type: ActivityType.study,
        dayType: DayType.weekday,
      ),
      Activity(
        id: 'gym',
        name: 'باشگاه',
        startTime: const TimeOfDaySimple(17, 0),
        endTime: const TimeOfDaySimple(19, 0),
        type: ActivityType.gym,
        dayType: DayType.weekday,
      ),
      Activity(
        id: 'dinner',
        name: 'شام و استراحت',
        startTime: const TimeOfDaySimple(19, 0),
        endTime: const TimeOfDaySimple(21, 0),
        type: ActivityType.rest,
        dayType: DayType.weekday,
      ),
      Activity(
        id: 'review',
        name: 'مرور تست‌ها',
        startTime: const TimeOfDaySimple(21, 0),
        endTime: const TimeOfDaySimple(22, 30),
        type: ActivityType.review,
        dayType: DayType.weekday,
      ),
      Activity(
        id: 'sleep',
        name: 'خواب',
        startTime: const TimeOfDaySimple(22, 30),
        endTime: const TimeOfDaySimple(6, 0),
        type: ActivityType.rest,
        dayType: DayType.weekday,
      ),
    ];

List<Activity> defaultWeekendActivities() => [
      Activity(
        id: 'wake_w',
        name: 'بیدار شدن',
        startTime: const TimeOfDaySimple(7, 0),
        endTime: const TimeOfDaySimple(7, 30),
        type: ActivityType.rest,
        dayType: DayType.weekend,
      ),
      Activity(
        id: 'chores',
        name: 'کارهای شخصی',
        startTime: const TimeOfDaySimple(7, 0),
        endTime: const TimeOfDaySimple(9, 0),
        type: ActivityType.other,
        dayType: DayType.weekend,
      ),
      Activity(
        id: 'study_w',
        name: 'مطالعه کنکور',
        startTime: const TimeOfDaySimple(9, 0),
        endTime: const TimeOfDaySimple(13, 0),
        type: ActivityType.study,
        dayType: DayType.weekend,
      ),
      Activity(
        id: 'lunch_w',
        name: 'ناهار و استراحت',
        startTime: const TimeOfDaySimple(13, 0),
        endTime: const TimeOfDaySimple(14, 0),
        type: ActivityType.rest,
        dayType: DayType.weekend,
      ),
      Activity(
        id: 'family',
        name: 'خانواده و دوستان',
        startTime: const TimeOfDaySimple(14, 0),
        endTime: const TimeOfDaySimple(17, 0),
        type: ActivityType.rest,
        dayType: DayType.weekend,
      ),
      Activity(
        id: 'gym_w',
        name: 'باشگاه',
        startTime: const TimeOfDaySimple(17, 0),
        endTime: const TimeOfDaySimple(19, 0),
        type: ActivityType.gym,
        dayType: DayType.weekend,
      ),
      Activity(
        id: 'family2',
        name: 'شام و خانواده',
        startTime: const TimeOfDaySimple(19, 0),
        endTime: const TimeOfDaySimple(21, 0),
        type: ActivityType.rest,
        dayType: DayType.weekend,
      ),
      Activity(
        id: 'review_w',
        name: 'مرور تست‌ها',
        startTime: const TimeOfDaySimple(21, 0),
        endTime: const TimeOfDaySimple(22, 30),
        type: ActivityType.review,
        dayType: DayType.weekend,
      ),
      Activity(
        id: 'sleep_w',
        name: 'خواب',
        startTime: const TimeOfDaySimple(22, 30),
        endTime: const TimeOfDaySimple(7, 0),
        type: ActivityType.rest,
        dayType: DayType.weekend,
      ),
    ];

List<Challenge> getDailyChallenges(bool isPersian) => [
      Challenge(
        id: 'ch1',
        titleFa: 'بیرون از خونه درس بخون',
        titleEn: 'Study outside your home',
        points: 30,
      ),
      Challenge(
        id: 'ch2',
        titleFa: 'همه فعالیت‌ها رو کامل کن',
        titleEn: 'Complete all activities',
        points: 50,
      ),
      Challenge(
        id: 'ch3',
        titleFa: 'یک پومودورو کامل انجام بده',
        titleEn: 'Complete one full Pomodoro',
        points: 20,
      ),
      Challenge(
        id: 'ch4',
        titleFa: 'یادداشت روزانه بنویس',
        titleEn: 'Write a daily note',
        points: 15,
      ),
      Challenge(
        id: 'ch5',
        titleFa: 'قبل از ۲۳ بخواب',
        titleEn: 'Sleep before 11 PM',
        points: 25,
      ),
    ];
