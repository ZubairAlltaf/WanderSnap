import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edt/data%20firestore/display_my_images.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/login.dart';
import '../screens/profile.dart';
import 'add_data_fst.dart';

class DisplayDataScreen extends StatelessWidget {
  const DisplayDataScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fireStore = FirebaseFirestore.instance.collectionGroup("posts");

    return Scaffold(

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurpleAccent, Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.deepPurple,
              elevation: 4,
              pinned: true,// pinned true to stop the scrolling of app bar
              title: const Text(
                "All Posts",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              leading: IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> DisplayImageScreen()));
              }, icon: Icon(Icons.image_search)),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white, size: 28),
                  tooltip: 'Profile',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                  tooltip: 'Logout',
                  onPressed: () => _logout(context),
                ),
              ],
            ),
            SliverFillRemaining(
              child: StreamBuilder<QuerySnapshot>(
                stream: fireStore.orderBy("timestamp", descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    print("Firestore Error: ${snapshot.error}");
                    return Center(
                      child: Text(
                        "Error loading data: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final title = docs[index]["title"];
                        final id = docs[index].id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: Colors.white,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 15.0,
                              ),
                              leading: const Icon(
                                Icons.post_add,
                                color: Colors.deepPurple,
                                size: 32.0,
                              ),
                              title: Text(
                                title ?? "No Title",
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.deepPurpleAccent,
                                size: 16,
                              ),
                              onTap: () {

                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No posts available",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDataFst()));
        },
        backgroundColor: Colors.deepPurple,
        elevation: 6,
        tooltip: 'Add Post',
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}