import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edt/data%20firestore/upload_file.dart';
import 'package:edt/data%20firestore/upload_image_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/login.dart';
import '../widgets/rounded_button.dart';
import '../widgets/utils.dart';

class AddDataFst extends StatefulWidget {
  const AddDataFst({super.key});

  @override
  State<AddDataFst> createState() => _AddDataFstState();
}

class _AddDataFstState extends State<AddDataFst> {
  TextEditingController postController = TextEditingController();
  bool loading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  Future<void> addPost() async {
    String postText = postController.text.trim();
    if (postText.isEmpty) {
      Utils().toastMessage("Post cannot be empty");
      return;
    }

    setState(() => loading = true);

    String id = DateTime.now().microsecondsSinceEpoch.toString();
    User? user = _auth.currentUser;

    if (user == null) {
      Utils().toastMessage("You must be logged in to post");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
      setState(() => loading = false);
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("posts")
          .doc(id)
          .set({
        "title": postText,
        "id": id,
        "uid": user.uid,
        "timestamp": FieldValue.serverTimestamp(),
      });

      postController.clear();
      Utils().toastMessage("Post added successfully");
      Navigator.pop(context);
    } catch (e) {
      Utils().toastMessage("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    Utils().toastMessage("Logged out successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple,
              Colors.deepPurpleAccent,
              Colors.white,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Center(child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Add Post",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    IconButton(
                      icon: Center(child: const Icon(Icons.upload, color: Colors.grey, size: 24)),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> UploadImageScreen())),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                      tooltip: 'Logout',
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: postController,
                          maxLines: 5,
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: "What’s on your mind?",
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      RoundButton(
                        title: "Add Post",
                        loading: loading,
                        onTap: addPost,

                        color: Colors.deepPurpleAccent,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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