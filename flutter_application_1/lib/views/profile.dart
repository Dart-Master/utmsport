import 'package:flutter/material.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'package:image_picker/image_picker.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileViewModel _viewModel = ProfileViewModel();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    await _viewModel.initialize();
    _nameController.text = _viewModel.name ?? '';
    _aboutController.text = _viewModel.aboutMe ?? '';
    _educationController.text = _viewModel.education ?? '';
    _phoneController.text = _viewModel.phone ?? '';
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage(String type) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        if (type == 'profile') {
          await _viewModel.uploadProfileImage(pickedFile.path);
        } else {
          await _viewModel.uploadHeaderImage(pickedFile.path);
        }
        await _loadUserData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await _viewModel.updateProfile(
        name: _nameController.text,
        aboutMe: _aboutController.text,
        education: _educationController.text,
        phone: _phoneController.text,
      );
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveChanges,
              child: const Text('SAVE', style: TextStyle(color: Colors.white)),
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Image
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: _viewModel.headerImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(_viewModel.headerImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.grey[300],
                        ),
                      ),
                      if (_isEditing)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit Header'),
                            onPressed: () => _pickImage('header'),
                          ),
                        ),
                    ],
                  ),

                  // Profile Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: _viewModel.profileImageUrl != null
                                    ? NetworkImage(_viewModel.profileImageUrl!)
                                    : null,
                                child: _viewModel.profileImageUrl == null
                                    ? const Icon(Icons.person, size: 60)
                                    : null,
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.white),
                                      onPressed: () => _pickImage('profile'),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _isEditing
                            ? TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: 'Name'),
                              )
                            : Center(
                                child: Text(
                                  _viewModel.name ?? 'No name set',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                        Center(
                          child: Text(
                            'Computer Science Student',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // About Me
                        const Text(
                          'About me',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _isEditing
                            ? TextField(
                                controller: _aboutController,
                                decoration: const InputDecoration(labelText: 'About me'),
                                maxLines: 3,
                              )
                            : Text(_viewModel.aboutMe ?? 'No description set'),
                        const SizedBox(height: 20),

                        // Phone
                        const Text(
                          'Phone Number',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _isEditing
                            ? TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(labelText: 'Phone Number'),
                              )
                            : Text(_viewModel.phone ?? 'No phone number set'),
                        const SizedBox(height: 20),

                        // Education
                        const Text(
                          'Education',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _isEditing
                            ? TextField(
                                controller: _educationController,
                                decoration: const InputDecoration(labelText: 'Education'),
                              )
                            : Text(_viewModel.education ?? 'No education set'),

                        if (_isEditing) ...[
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveChanges,
                              child: const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _educationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
