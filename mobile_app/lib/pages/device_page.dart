import 'package:capstone_2023/controllers/tts_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final _controller = Get.put(TtsController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              // User swiped Left
              Get.back();
            } else if (details.primaryVelocity! < 0) {
              // User swiped Right
            }
          },
          child: StreamBuilder(
            stream: _db.collection("messages").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Network Error');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final documents = snapshot.data!.docs;
              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final document = documents[index];
                  // new message -> TTS
                  _controller.speak(document["msg"]);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 30,
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      tileColor: Colors.white,
                      textColor: Colors.black,
                      title: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 50,
                          horizontal: 16,
                        ),
                        child: Text(
                          document['msg'],
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
