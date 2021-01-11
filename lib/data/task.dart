class Task {
  final String id;
  final String title;
  final String description;
  final String imageId;

  Task({this.id, this.title, this.description, this.imageId});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
        id: json['_id'],
        title: json['title'],
        description: json['description'],
        imageId: json['imageId']);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'imageId': imageId,
    };
  }
}
