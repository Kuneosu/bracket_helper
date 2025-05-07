class Contributor {
  final String name;
  final String role;
  final String color;

  Contributor({
    required this.name,
    required this.role,
    this.color = "default",
  });

  factory Contributor.fromJson(Map<String, dynamic> json) {
    return Contributor(
      name: json['name'] as String,
      role: json['role'] as String,
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'color': color,
    };
  }
} 