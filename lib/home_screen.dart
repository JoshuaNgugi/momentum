import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:momentum/auth_service.dart';

var logger = Logger(printer: PrettyPrinter());

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService(); // Instantiate Auth Service
  XFile? _selectedMedia;
  bool _isUploading = false;

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
      logger.e('Error picking media: $e');
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

  Future<void> _uploadMedia() async {
    if (_selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select media first!')),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to upload media.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String mediaType = _isMediaTypeVideo(_selectedMedia) ? 'video' : 'image';
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_selectedMedia!.name}';
      // Store in a user-specific folder for better organization and security rules
      String storagePath = 'user_uploads/${user.uid}/$fileName';
      Reference storageRef = FirebaseStorage.instance.ref().child(storagePath);

      UploadTask uploadTask;

      if (mediaType == 'image') {
        final filePath = _selectedMedia!.path;
        final targetPath = '${filePath}_compressed.jpg';

        final originalFile = File(_selectedMedia!.path);
        final originalFileSize = await originalFile
            .length(); // Get size in bytes
        logger.i(
          'Original image file size: ${originalFileSize / (1024 * 1024)} MB',
        );

        var result = await FlutterImageCompress.compressAndGetFile(
          filePath,
          targetPath,
          minWidth: 1080,
          minHeight: 1080,
          quality: 75,
        );

        if (result == null) {
          throw Exception('Image compression failed.');
        }

        final compressedFileSize = await File(result.path).length();
        logger.i(
          'Compressed image file size: ${compressedFileSize / (1024 * 1024)} MB',
        );
        logger.i(
          'Compression Ratio: ${(compressedFileSize / originalFileSize * 100).toStringAsFixed(2)}%',
        );

        // Upload the compressed file
        uploadTask = storageRef.putFile(File(result.path));
      } else {
        // For video, we'll just upload the original file for now.
        // Video compression/transcoding is typically done server-side (Cloud Functions).
        uploadTask = storageRef.putFile(File(_selectedMedia!.path));
      }

      // Await the completion of the upload task
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save metadata to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': user.uid,
        'mediaUrl': downloadUrl,
        'mediaPath':
            storagePath, // Store path for potential future operations (e.g., deletion)
        'mediaType': mediaType,
        'timestamp':
            FieldValue.serverTimestamp(), // Firestore server timestamp for consistency
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Media uploaded successfully!')),
      );

      // Clear selected media after successful upload
      setState(() {
        _selectedMedia = null;
      });
    } on FirebaseException catch (e) {
      logger.e('Firebase Upload Error: ${e.message}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: ${e.message}')));
    } catch (e) {
      logger.e('General Upload Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred during upload: $e'),
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
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
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Welcome to Momentum!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Upload your daily recap!',
                  style: TextStyle(fontSize: 18),
                ),
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
                      label: const Text(
                        'Take Photo',
                      ), // Updated label for clarity
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
                              )
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
                      _isUploading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              onPressed: _uploadMedia,
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text('Upload Media'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                      const SizedBox(height: 20),
                    ],
                  )
                else
                  const Text('No media selected yet. Pick one to upload!'),
              ],
            ),
          ),
          const Divider(),
          const Text(
            'Your Uploaded Recaps:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseAuth.instance.currentUser != null
                  ? FirebaseFirestore.instance
                        .collection('posts')
                        .where(
                          'userId',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                        )
                        .orderBy(
                          'timestamp',
                          descending: true,
                        ) // Order by latest posts
                        .snapshots()
                  : const Stream.empty(), // Return empty stream if no user
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading posts: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No recaps uploaded yet.'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    String mediaUrl = data['mediaUrl'] ?? '';
                    String mediaType = data['mediaType'] ?? 'image';
                    Timestamp? timestamp = data['timestamp'];

                    // Format timestamp if available
                    String formattedTime = timestamp != null
                        ? DateTime.fromMillisecondsSinceEpoch(
                            timestamp.millisecondsSinceEpoch,
                          ).toLocal().toString().split('.')[0]
                        : 'Unknown time';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (mediaType == 'image')
                              Center(
                                child: Image.network(
                                  mediaUrl,
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.broken_image,
                                        size: 100,
                                        color: Colors.red,
                                      ),
                                ),
                              )
                            else if (mediaType == 'video')
                              Center(
                                child: Container(
                                  height: 250,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.videocam,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                      Text(
                                        'Video content (player coming soon!)',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              'Uploaded: $formattedTime',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
