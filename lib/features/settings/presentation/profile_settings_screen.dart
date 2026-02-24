import 'package:flutter/material.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _emailController = TextEditingController(text: 'admin@evoca.com');
  final _passwordController = TextEditingController(text: '••••••••');
  
  bool _isEditingEmail = false;
  bool _isEditingPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 32),
          
          _buildEditableField(
            'Email Address',
            _emailController,
            _isEditingEmail,
            () => setState(() => _isEditingEmail = !_isEditingEmail),
            TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 24),
          
          _buildEditableField(
            'Password',
            _passwordController,
            _isEditingPassword,
            () => setState(() => _isEditingPassword = !_isEditingPassword),
            TextInputType.visiblePassword,
            obscureText: !_isEditingPassword,
          ),
          
          const SizedBox(height: 48),
          
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
              Navigator.pop(context);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label, 
    TextEditingController controller, 
    bool isEditing, 
    VoidCallback onToggle,
    TextInputType keyboardType,
    {bool obscureText = false}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: isEditing,
                obscureText: obscureText,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  border: isEditing ? const UnderlineInputBorder() : InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit, size: 20),
              onPressed: onToggle,
              color: isEditing ? Colors.green : Colors.blueGrey,
            ),
          ],
        ),
      ],
    );
  }
}
