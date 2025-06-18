import 'package:flutter/material.dart';
import 'user_account_management.dart';
import 'analytic_dashboard.dart'; // Add this import
import 'booking_management.dart';
import 'login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Bar with Buttons and Image Ads',
      home: const AdminDashboard(),
      routes: {
        '/page1': (context) => const BookingManagementPage(),
        '/page2': (context) => const UserAccountManagementPage(),
        '/page3': (context) =>
            const AnalyticDashboardPage(), // This should now work
      },
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          ),
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back, admin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
        if (route == '/page2') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserAccountManagementPage(),
            ),
          );
        } else if (route == '/page3') {
          // Add explicit navigation for page3 as well
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnalyticDashboardPage(),
            ),
          );
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
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
                color: Colors.black12, blurRadius: 3, offset: Offset(1, 1)),
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
                color: Colors.black12, blurRadius: 3, offset: Offset(1, 1)),
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





// Remove the dummy Page3 class since we're using AnalyticDashboardPage from analytic_dashboard.dart