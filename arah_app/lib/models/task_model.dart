class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}
