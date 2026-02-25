import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/models/models.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    final user = provider.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _profileImageBase64 = _extractBase64FromProfileImage(user?.profileImage);
  }

  String? _extractBase64FromProfileImage(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) return null;
    if (profileImage.startsWith('data:')) {
      final parts = profileImage.split(',');
      return parts.length > 1 ? parts[1] : null;
    }
    if (!profileImage.contains('/') && !profileImage.contains('\\')) {
      return profileImage;
    }
    return null;
  }

  Future<void> _pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;
      final bytes = await image.readAsBytes();
      if (mounted) {
        setState(() {
          _profileImageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    
    final provider = Provider.of<AppProvider>(context, listen: false);
    final profileImage = _profileImageBase64 != null
        ? 'data:image/jpeg;base64,$_profileImageBase64'
        : provider.currentUser?.profileImage;
    final updatedUser = User(
      name: _nameController.text,
      email: _emailController.text,
      profileImage: profileImage,
    );
    
    await provider.updateProfile(updatedUser);
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blueGrey,
                        backgroundImage: _profileImageBase64 != null
                            ? MemoryImage(base64Decode(_profileImageBase64!))
                            : null,
                        child: _profileImageBase64 == null
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt, size: 20, color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 48),
              
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () async {
                  final provider = Provider.of<AppProvider>(context, listen: false);
                  final navigator = Navigator.of(context);
                  await provider.logout();
                  if (mounted) {
                    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
