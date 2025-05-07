class AppConfig {
  final String version;
  final List<Map<String, dynamic>> contributors;

  AppConfig({
    required this.version,
    required this.contributors,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      version: json['version'] as String,
      contributors: List<Map<String, dynamic>>.from(
        (json['contributors'] as List).map((x) => Map<String, dynamic>.from(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'contributors': contributors,
    };
  }
} 