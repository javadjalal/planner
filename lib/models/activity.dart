class Activity {
  final String id;
  final String name;
  final String? category;
  final String? startTime;
  final String? endTime;
  final bool completed;
  final int priority;
  final String? color;
  final String? description;

  Activity({
    required this.id,
    required this.name,
    this.category,
    this.startTime,
    this.endTime,
    this.completed = false,
    this.priority = 0,
    this.color,
    this.description,
  });

  Activity copyWith({
    String? id,
    String? name,
    String? category,
    String? startTime,
    String? endTime,
    bool? completed,
    int? priority,
    String? color,
    String? description,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'startTime': startTime,
      'endTime': endTime,
      'completed': completed,
      'priority': priority,
      'color': color,
      'description': description,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      completed: json['completed'] ?? false,
      priority: json['priority'] ?? 0,
      color: json['color'],
      description: json['description'],
    );
  }
}
