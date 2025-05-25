import '../models/user_model.dart';

class LoginViewModel {
  final List<User> _users = [
    User(email: "student@utm.my", password: "password123", role: "student"),
    User(email: "admin@utm.my", password: "admin123", role: "admin"),
  ];

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    try {
      return _users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }
}
