class UserModel {
  final String username;
  final String toLang; // Language user wants to learn
  final String fromLang; // Native language
  final String level; // Language proficiency level (e.g., A1 to C2)

  UserModel({
    required this.username,
    required this.toLang,
    required this.fromLang,
    required this.level,
  });

  // Convert to Map (for SharedPreferences or JSON)
  Map<String, String> toMap() {
    return {
      'username': username.toLowerCase(),
      'tolang': toLang.toLowerCase(),
      'fromlang': fromLang.toLowerCase(),
      'level': level.toLowerCase(),
    };
  }

  // Create UserModel from Map (e.g. from SharedPreferences)
  factory UserModel.fromMap(Map<String, String> map) {
    return UserModel(
      username: map['username'] ?? '',
      toLang: map['tolang'] ?? '',
      fromLang: map['fromlang'] ?? '',
      level: map['level'] ?? '',
    );
  }
}
