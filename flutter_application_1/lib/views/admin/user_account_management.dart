import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAccountManagementPage extends StatefulWidget {
  const UserAccountManagementPage({super.key});

  @override
  State<UserAccountManagementPage> createState() =>
      _UserAccountManagementPageState();
}

class _UserAccountManagementPageState extends State<UserAccountManagementPage> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');
  final List<String> roles = ['student', 'admin', 'organizer'];
  final TextEditingController searchController = TextEditingController();
  
  String selectedFilter = 'All Users';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('User Account Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.blue, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Filter buttons
                Row(
                  children: [
                    _buildFilterChip('All Users'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Student'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Organizers'),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.search, color: Colors.white, size: 20),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          // User List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                final users = snapshot.data!.docs.where((user) {
                  final userData = user.data() as Map<String, dynamic>;
                  final name = (userData['name'] ?? '').toString().toLowerCase();
                  final email = (userData['email'] ?? '').toString().toLowerCase();
                  final role = userData['role'] ?? 'student';

                  // Filter by search query
                  bool matchesSearch = searchQuery.isEmpty ||
                      name.contains(searchQuery) ||
                      email.contains(searchQuery);

                  // Filter by selected role
                  bool matchesRole = selectedFilter == 'All Users' ||
                      (selectedFilter == 'Student' && role == 'student') ||
                      (selectedFilter == 'Organizers' && role == 'organizer');

                  return matchesSearch && matchesRole;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userData = user.data() as Map<String, dynamic>;
                    return _buildUserCard(user, userData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(DocumentSnapshot user, Map<String, dynamic> userData) {
    final name = userData['name'] ?? 'No Name';
    final email = userData['email'] ?? 'No Email';
    final role = userData['role'] ?? 'student';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Action buttons
          role == 'student'
              ? _buildActionButton(
                  'Edit Role',
                  Colors.blue,
                  () => _showRoleDialog(user, userData),
                )
              : _buildActionButton(
                  'Edit Role',
                  Colors.blue,
                  () => _showRoleDialog(user, userData),
                ),
          const SizedBox(width: 8),
          _buildActionButton(
            'Remove',
            Colors.blue,
            () => _showDeleteDialog(user, userData),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showRoleDialog(DocumentSnapshot user, Map<String, dynamic> userData) async {
    final currentRole = userData['role'] ?? 'student';
    String? selectedRole = currentRole;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Change role for ${userData['name'] ?? userData['email']}'),
            const SizedBox(height: 16),
            ...roles.map((role) {
              return RadioListTile<String>(
                title: Text(role.toUpperCase()),
                value: role,
                groupValue: selectedRole,
                onChanged: (value) {
                  selectedRole = value;
                  Navigator.pop(context, value);
                },
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null && result != currentRole) {
      try {
        await usersRef.doc(user.id).update({'role': result});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Role updated to ${result.toUpperCase()}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating role: $e')),
          );
        }
      }
    }
  }

  Future<void> _showDeleteDialog(DocumentSnapshot user, Map<String, dynamic> userData) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove User'),
        content: Text('Are you sure you want to remove ${userData['name'] ?? userData['email']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await usersRef.doc(user.id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User removed successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error removing user: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}