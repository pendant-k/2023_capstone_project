import 'package:capstone_2023/controllers/guardian_number_controller.dart';
import 'package:capstone_2023/controllers/tts_controller.dart';
import 'package:capstone_2023/models/page_content.dart';
import 'package:capstone_2023/pages/application_page.dart';
import 'package:capstone_2023/pages/dashcam_page.dart';
import 'package:capstone_2023/pages/device_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';

import 'dashcam_list_page.dart';

final List<PageContent> pages = [
  PageContent(
    pageName: "Connect\nDevice",
    pageIcon: Icons.phone_android_outlined,
    guide: "Connect to device and get the guide",
  ),
  PageContent(
    pageName: "Application\nSetting",
    pageIcon: Icons.settings_cell,
    guide: 'This is application setting page',
  ),
  PageContent(
      pageName: "Call to\nNext of Kin",
      pageIcon: Icons.call,
      guide:
          "If you configured your guardian's information before,\n On this page, you can call your guardian directly."),
  PageContent(
    pageName: "Dash\nCam",
    pageIcon: Icons.video_collection,
    guide: "This is dash cam page",
  ),
];

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ttsController = Get.put(TtsController());
  // dependency injection
  final guardianController = Get.put(GuardianController());
  @override
  void initState() {
    super.initState();

    // 최초 실행시에만 실행되도록 변경해야함
    ttsController.setLanguage('en');
    ttsController.setSpeechRate(0.4);
    // ttsController.speak(VoiceGuide.INITGUIDE);
  }

  var pageIdx = 0;

  void shuffle(String direction) {
    if (direction == "up") {
      if (pageIdx < pages.length - 1) {
        setState(() {
          pageIdx++;
        });
      } else {
        setState(() {
          pageIdx = 0;
        });
      }
    } else {
      if (pageIdx - 1 < 0) {
        setState(() {
          pageIdx = pages.length - 1;
        });
      } else {
        setState(() {
          pageIdx--;
        });
      }
    }
    final convertedTexts = pages[pageIdx].pageName.split("\n");
    ttsController.speak(convertedTexts[0] + " " + convertedTexts[1]);
    //ttsController
  }

  _callNumber() async {
    const number = '01030509283'; //set the number here
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Text(
                    "Your",
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Daily Vision",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 35),
            GestureDetector(
              onLongPress: () {
                // ttsController speak guide
                print("This is Long Press");
                ttsController.speak(pages[pageIdx].guide);
              },
              onTap: () {
                switch (pageIdx) {
                  // case 0:
                  //   Get.to(() => DevicePage());
                  //   break;
                  case 0:
                    Get.to(() => DevicePage());
                    break;
                  case 1:
                    Get.to(() => ApplicationPage());
                    break;
                  case 2:
                    // Make a call to guardian
                    _callNumber();
                    break;
                  case 3:
                    Get.to(() => DashCamListPage());
                }
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  shuffle("up");
                } else {
                  shuffle("down");
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        pages[pageIdx].pageIcon,
                        size: 150,
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        pages[pageIdx].pageName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/* TODO : 
[] getx debug
[] UI for app setting page (same with main page, gesture)
[] Guardian phone number store to shared preferences

*/


// 방향, 거리, 장애물 탐지 -> 
// next of kin