import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../widgets/utils.dart';

class DisplayImageScreen extends StatefulWidget {
  const DisplayImageScreen({Key? key}) : super(key: key);

  @override
  State<DisplayImageScreen> createState() => _DisplayImageScreenState();
}

class _DisplayImageScreenState extends State<DisplayImageScreen> {
  bool isLoading = true;
  List<String> imageUrls = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final DatabaseReference databaseRef;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance.ref('images');
    checkInternetAndFetch();
  }

  Future<void> checkInternetAndFetch() async {
    await checkInternetConnection();
    if (hasInternet) {
      await fetchImages();
    } else {
      setState(() => isLoading = false);
      Utils().toastMessage("No internet connection");
    }
  }

  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      hasInternet = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> fetchImages() async {
    User? user = _auth.currentUser;
    if (user == null) {
      Utils().toastMessage("Please log in to view images");
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);

    try {
      DatabaseEvent event = await databaseRef.child(user.uid).once();
      DataSnapshot snapshot = event.snapshot;

      imageUrls.clear();
      if (snapshot.value != null) {
        Map<dynamic, dynamic> images = snapshot.value as Map<dynamic, dynamic>;
        images.forEach((key, value) {
          if (value['url'] != null) {
            imageUrls.add(value['url']);
          }
        });
      }

      setState(() => isLoading = false);
    } catch (error) {
      Utils().toastMessage("Error fetching images: $error");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Images'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: checkInternetAndFetch,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.deepPurple),
              const SizedBox(height: 16),
              Text(
                'Loading your images...',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        )
            : !hasInternet
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 60,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your connection and try again',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: checkInternetAndFetch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : imageUrls.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 60,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'No Images Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload some images to see them here',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        )
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          padding: const EdgeInsets.all(16),
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                cacheWidth: 512,
                cacheHeight: 512,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.deepPurple,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            );
          },        ),
      ),
    );
  }
}