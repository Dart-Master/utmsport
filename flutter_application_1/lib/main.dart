import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'views/login_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTM Sports',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF800000),
          primaryContainer: const Color(0xFF500000),
        ),
      ),
      home: const LoginPage(),
    );
  }
}