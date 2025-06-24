import 'package:flutter/material.dart';

class UserAccountPage extends StatelessWidget {
  const UserAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> users = [
      {'name': 'ALI HARIZ BIN ANUARI', 'email': 'alihariZ0101@gmail.com', 'role': 'Edit Role'},
      {'name': 'ZUBAIDAH BINTI ALI', 'email': 'zubaidah21B8@gmail.com', 'role': 'Remove'},
      {'name': 'SOFYAN BIN SUHAIMI', 'email': 'sofyang299@gmail.com', 'role': 'Remove'},
      {'name': 'BUDIMAN BIN YAHYA', 'email': 'juanbudiman@gmail.com', 'role': 'Edit Role'},
      {'name': 'AQIL BIN HAZIQ', 'email': 'aqilhaziq1001@gmail.com', 'role': 'Edit Role'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Account Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips
            Row(
              children: [
                _buildFilterChip("All Users", true),
                const SizedBox(width: 8),
                _buildFilterChip("Student", false),
                const SizedBox(width: 8),
                _buildFilterChip("Organizers", false),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // User List
            Expanded(
              child: ListView.separated(
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(user['email']!),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text(user['role']!),
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
      selectedColor: Colors.grey.shade300,
      backgroundColor: Colors.grey.shade200,
    );
  }
}
