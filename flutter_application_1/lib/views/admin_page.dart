import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'user_account_management.dart';
import 'analytic_dashboard.dart';
import 'booking_management.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';

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
      title: 'Admin Dashboard',
      home: const AdminDashboard(),
      routes: {
        '/page1': (context) => const BookingManagementPage(),
        '/page2': (context) => const UserAccountManagementPage(),
        '/page3': (context) => const AnalyticDashboardPage(),
        '/edit_profile': (context) => const EditProfilePage(),
      },
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Profile Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile Picture
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Admin Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'John Doe',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'admin@example.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Administrator',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit Profile Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/edit_profile');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Welcome Message
              const Text(
                'Welcome back, admin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Management Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRectangleButton(
                    context,
                    'Booking Management',
                    Colors.blue,
                    '/page1',
                    icon: Icons.book_online,
                  ),
                  _buildRectangleButton(
                    context,
                    'User Account Management',
                    Colors.blue,
                    '/page2',
                    icon: Icons.person,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: _buildRectangleButton(
                  context,
                  'Analytic Dashboard',
                  Colors.blue,
                  '/page3',
                  width: 200,
                  icon: Icons.analytics,
                ),
              ),
              const SizedBox(height: 32),

              // Important Events Section
              const Text(
                'Important Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _buildImageAdBoardAsset('assets/images/ADS.png'),
              const SizedBox(height: 16),
              _buildImageAdBoardNetwork(
                  'https://picsum.photos/600/200?grayscale'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRectangleButton(
    BuildContext context,
    String text,
    Color color,
    String route, {
    double width = 150,
    double height = 120,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageAdBoardAsset(String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
      ),
    );
  }

  Widget _buildImageAdBoardNetwork(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
      ),
    );
  }
}
