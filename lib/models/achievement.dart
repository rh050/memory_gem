class Achievement {
  final String id;
  final String title;
  final String description;
  final bool achieved;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.achieved,
  });

  Achievement copyWith({bool? achieved}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      achieved: achieved ?? this.achieved,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'achieved': achieved,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      achieved: json['achieved'] ?? false,
    );
  }
}
