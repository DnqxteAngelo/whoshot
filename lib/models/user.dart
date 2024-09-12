class User {
  final int? userId;
  final String userStudentId;
  final String userFullname;
  final String? userSection;

  User({
    required this.userId,
    required this.userStudentId,
    required this.userFullname,
    required this.userSection,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      userStudentId: json['user_studentId'] ?? '',
      userFullname: json['user_name'] ?? '',
      userSection: json['user_section'] ?? '',
    );
  }
}
