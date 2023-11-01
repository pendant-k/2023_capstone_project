import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/page_content.dart';

import '../controllers/guardian_number_controller.dart';
import '../controllers/tts_controller.dart';

final List<PageContent> pages = [
  PageContent(
    pageName: "Increase\nSpeech Rate",
    pageIcon: Icons.arrow_upward,
    guide: 'Touch to Increase Speech Rate',
  ),
  PageContent(
      pageName: "Decrease\nSpeech Rate",
      pageIcon: Icons.arrow_downward,
      guide: "Touch to Decrease Speech Rate"),
  PageContent(
    pageName: "Change\n Next of Kin",
    pageIcon: Icons.person,
    guide: "This is dash cam page",
  ),
];

class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  var pageIdx = 0;
  final ttsController = Get.put(TtsController());
  // dependency injection
  final guardianController = Get.put(GuardianController());

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

  void _increaseRate() {
    ttsController.increaseRate();
  }

  void _decreaseRate() {
    ttsController.decreaseRate();
  }

  @override
  void initState() {
    super.initState();
    final convertedTexts = pages[pageIdx].pageName.split("\n");
    ttsController.speak("Application Setting Page," +
        convertedTexts[0] +
        " " +
        convertedTexts[1]);
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
                    "Application",
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Setting",
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
                  // shuffle bu page index
                  case 0:
                    _increaseRate();
                    ttsController.speak("Current Speech Rate");
                    break;
                  case 1:
                    _decreaseRate();
                    ttsController.speak("Current Speech Rate");
                    break;
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

// TODO :
// [ ] Change speech rate
// [ ] Firestore setting -> Stream