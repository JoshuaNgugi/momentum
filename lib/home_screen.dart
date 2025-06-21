// screens/home_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:momentum/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService(); // Instantiate Auth Service
  XFile? _selectedMedia;

  Future<void> _pickMedia(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    XFile? media;

    try {
      if (source == ImageSource.gallery) {
        media = await picker
            .pickMedia(); // Allows picking both images and videos
      } else {
        // ImageSource.camera
        // TODO: provide separate buttons for camera image and video
        // For simplicity, let's allow general media pick from camera if source is camera
        // Or specify pickImage or pickVideo explicitly
        media = await picker.pickImage(
          source: source,
        ); // For now, camera picks images
        // Add pick video from camera later via : media = await picker.pickVideo(source: source);
      }

      setState(() {
        _selectedMedia = media;
      });
    } catch (e) {
      print('Error picking media: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to pick media')));
    }
  }

  // Helper to determine if the selected media is a video
  bool _isMediaTypeVideo(XFile? media) {
    if (media == null) return false;
    // Simple check based on file extension
    final String extension = media.path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              // StreamBuilder in main.dart will automatically navigate to LoginScreen
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Momentum!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('You are logged in.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickMedia(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pick from Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickMedia(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo/Video'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (_selectedMedia != null)
              Column(
                children: [
                  Text(
                    'Selected Media: ${_selectedMedia!.name}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isMediaTypeVideo(_selectedMedia)
                        ? const Center(
                            child: Icon(
                              Icons.videocam,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ) // Placeholder for video
                        : Image.file(
                            File(_selectedMedia!.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.red,
                                ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  // TODO: Add Upload button here in the next step
                ],
              )
            else
              const Text('No media selected yet.'),
          ],
        ),
      ),
    );
  }
}
