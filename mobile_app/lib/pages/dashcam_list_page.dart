import 'package:capstone_2023/pages/dashcam_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashCamListPage extends StatefulWidget {
  const DashCamListPage({super.key});

  @override
  State<DashCamListPage> createState() => _DashCamListPageState();
}

class _DashCamListPageState extends State<DashCamListPage> {
  final storage = FirebaseStorage.instance;

  Future<List<Reference>> getStorageFiles() async {
    List<Reference> files = [];

    try {
      Reference storageRef = storage.ref("/");

      // List all items (files and folders) in the root reference
      ListResult result = await storageRef.listAll();

      // Filter out only the files
      for (Reference ref in result.items) {
        files.add(ref);
      }
    } catch (e) {
      // Handle any errors
      print('Error retrieving storage files: $e');
    }

    return files;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<List<Reference>>(
          future: getStorageFiles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            List<Reference>? files = snapshot.data;

            if (files == null || files.isEmpty) {
              return Center(child: Text('No files found'));
            }

            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                Reference file = files[index];
                return GestureDetector(
                  onTap: () async {
                    final fileUrl = await file.getDownloadURL();
                    Get.to(() => DashCamPage(fileUrl: fileUrl));
                  },
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(file.name),
                      leading: Icon(Icons.video_library),
                      subtitle: Text(file.fullPath),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
