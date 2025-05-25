class User {
  final String email;
  final String password;
  final String role; // "student" or "admin"

  User({required this.email, required this.password, required this.role});
}
