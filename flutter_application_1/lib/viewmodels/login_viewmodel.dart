import '../models/user_model.dart';

class LoginViewModel {
  final User _validUser = User(
    email: "student@utm.my",
    password: "password123",
  );

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return email == _validUser.email && password == _validUser.password;
  }
}
