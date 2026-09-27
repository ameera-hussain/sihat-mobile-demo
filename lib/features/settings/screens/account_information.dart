import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../mock_data/mock_auth.dart';
import 'package:image_picker/image_picker.dart';

///mock data used for account information screen from features/auth/mock_auth.dart

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  State<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  Set<String> selectedNotifications = {'email'};
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController carePlanController;
  bool isEditMode = false;

  // Uint8List + MemoryImage instead of dart:io File + FileImage — this
  // works identically on mobile, desktop, AND web. dart:io.File does not
  // exist on web and would break that build target.
  Uint8List? profileImageBytes;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: MockAuth.mockUser.name ?? '');
    emailController = TextEditingController(text: MockAuth.mockUser.email);
    phoneController = TextEditingController(text: '+1 234 567 890');
    carePlanController = TextEditingController(text: 'N/A');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    carePlanController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        // Downsample at pick-time so a 10-20MB phone photo doesn't sit
        // in memory just to render a 120x120 avatar circle.
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();

      // Guard against the widget having been disposed during the
      // await (e.g. user backed out of this screen mid-pick).
      if (!mounted) {
        return;
      }

      setState(() {
        profileImageBytes = bytes;
      });
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/settings');
          },
        ),
        title: const Text('Account Information'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      backgroundImage: profileImageBytes != null
                          ? MemoryImage(profileImageBytes!)
                          : null,
                      child: profileImageBytes == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 8)],
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF5D53A3),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _pickProfileImage,
                            borderRadius: BorderRadius.circular(20),
                            child: const Icon(Icons.edit, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (isEditMode)
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    // TODO: Update auth when backend is ready
                  },
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nameController.text,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if (isEditMode)
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    // TODO: Update auth when backend is ready
                  },
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emailController.text,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if (isEditMode)
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    // TODO: Update auth when backend is ready
                  },
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone Number',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phoneController.text,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (isEditMode)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      // Handle change password
                    },
                    child: const Text('Change Password'),
                  ),
                ),
              const SizedBox(height: 16),
              if (isEditMode)
                TextField(
                  controller: carePlanController,
                  decoration: InputDecoration(
                    labelText: 'Care Plan Information',
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    // TODO: Update auth when backend is ready
                  },
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Care Plan Information',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        carePlanController.text,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Notification Preferences',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              if (isEditMode) ...[
                Material(
                  color: Colors.white,
                  child: CheckboxListTile(
                    title: const Text('Email'),
                    value: selectedNotifications.contains('email'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedNotifications.add('email');
                        } else {
                          selectedNotifications.remove('email');
                        }
                      });
                      // TODO: Update auth when backend is ready
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Material(
                  color: Colors.white,
                  child: CheckboxListTile(
                    title: const Text('SMS'),
                    value: selectedNotifications.contains('sms'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedNotifications.add('sms');
                        } else {
                          selectedNotifications.remove('sms');
                        }
                      });
                      // TODO: Update auth when backend is ready
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Material(
                  color: Colors.white,
                  child: CheckboxListTile(
                    title: const Text('Push Notifications'),
                    value: selectedNotifications.contains('push'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedNotifications.add('push');
                        } else {
                          selectedNotifications.remove('push');
                        }
                      });
                      // TODO: Update auth when backend is ready
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ] else ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedNotifications.isEmpty
                        ? 'None'
                        : selectedNotifications
                            .map((n) => n[0].toUpperCase() + n.substring(1))
                            .join(', '),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5D53A3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isEditMode = !isEditMode;
                    });
                  },
                  child: Text(
                    isEditMode ? 'Save' : 'Edit Information',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
