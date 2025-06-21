import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../widgets/rounded_button.dart';
import '../widgets/utils.dart';
import 'display_my_images.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({Key? key}) : super(key: key);

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  bool loading = false;
  File? _image;
  final picker = ImagePicker();
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final DatabaseReference databaseRef;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance.ref('images');
  }

  Future<void> getImageGallery() async {
    User? user = _auth.currentUser;
    if (user == null) {
      Utils().toastMessage("Please log in to select an image");
      return;
    }

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Lower quality to 70%
      maxWidth: 800,   // Reduce resolution
      maxHeight: 800,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }
  Future<void> uploadImageToStorage() async {
    User? user = _auth.currentUser;
    if (user == null) {
      Utils().toastMessage("Please log in to upload images");
      return;
    }

    if (_image == null) {
      Utils().toastMessage("Please select an image first");
      return;
    }

    setState(() => loading = true);

    try {
      String fileNameWithExt = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String fileName = fileNameWithExt.replaceAll('.jpg', '');
      firebase_storage.Reference ref = storage.ref().child('images/${user.uid}/$fileNameWithExt');

      await ref.putFile(_image!);
      String downloadUrl = await ref.getDownloadURL();

      await databaseRef.child(user.uid).child(fileName).set({
        'url': downloadUrl,
        'timestamp': ServerValue.timestamp,
      });

      Utils().toastMessage('Image uploaded successfully');
      setState(() => _image = null);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DisplayImageScreen()),
      );
    } catch (error) {
      Utils().toastMessage("Upload failed: $error");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: getImageGallery,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: _image != null ? Colors.deepPurple : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _image != null
                              ? Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            color: Colors.grey.shade200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Tap to select image',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                RoundButton(
                  title: 'Upload Image',
                  loading: loading,
                  onTap: uploadImageToStorage,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}