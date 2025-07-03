import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'views/booking_management.dart' show BookingManagementPage;
import 'views/user_auth/login_page.dart'; // Ensure this path is correct
// Import all the pages you're routing to
import 'views/admin/admin_page.dart'; // Or wherever your Page1 is located
import 'views/admin/user_account_management.dart'; // Import UserAccountManagementPage
import 'views/organizer/organizer_page.dart';

void main() async {
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
      debugShowCheckedModeBanner: false, // Disable debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF800000),
          primaryContainer: const Color(0xFF500000),
        ),
      ),
      home: const LoginPage(),
      routes: {
        '/admin': (context) =>
            const AdminDashboard(), // Add admin dashboard route
        '/page1': (context) => const BookingManagementPage(),
        '/page2': (context) => const UserAccountManagementPage(),
        '/organizer': (context) => const OrganizerPage(),
      },
    );
  }
}
