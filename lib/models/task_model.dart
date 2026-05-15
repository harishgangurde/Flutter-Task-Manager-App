class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isDone;
  final String userId;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.isDone,
    required this.userId,
    required this.createdAt,
  });

  // Convert Firestore document → TaskModel
  factory TaskModel.fromMap(Map<String, dynamic> data, String docId) {
    return TaskModel(
      id: docId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      isDone: data['isDone'] ?? false,
      userId: data['userId'] ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // Convert TaskModel → Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'isDone': isDone,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Creates a copy with specific fields changed (useful for toggle)
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? isDone,
    String? userId,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
