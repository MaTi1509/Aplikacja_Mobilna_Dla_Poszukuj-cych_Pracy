import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work_matcher_1/All%20Job%20Offers/all_job_offers_screen.dart';
import 'package:work_matcher_1/Jobs/jobs_screen.dart';
import 'package:work_matcher_1/Jobs/upload_job.dart';
import 'package:work_matcher_1/Search/profile_comapny.dart';
import 'package:work_matcher_1/Search/search_companies.dart';
import 'package:work_matcher_1/user_state.dart';

class BottomNavigationBarForApp extends StatefulWidget {
  int indexNum = 0;

  BottomNavigationBarForApp({required this.indexNum});

  @override
  State<BottomNavigationBarForApp> createState() => _BottomNavigationBarForAppState();
}

class _BottomNavigationBarForAppState extends State<BottomNavigationBarForApp> {
  List<Color> itemColors = [
    Colors.yellow,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CurvedNavigationBar(
      color: Colors.transparent,
      backgroundColor: Colors.transparent,
      buttonBackgroundColor: Colors.transparent,
      height: 50,
      index: widget.indexNum,
      items: <Widget>[
        Icon(Icons.list, size: 25, color: widget.indexNum == 0 ? Colors.yellow.shade700 : isDarkMode ? Colors.white : Colors.black),
        Icon(Icons.person_search, size: 25, color: widget.indexNum == 1 ? Colors.yellow.shade700 : isDarkMode ? Colors.white : Colors.black),
        Icon(Icons.add, size: 25, color: widget.indexNum == 2 ? Colors.yellow.shade700 : isDarkMode ? Colors.white : Colors.black),
        Icon(Icons.person, size: 25, color: widget.indexNum == 3 ? Colors.yellow.shade700 : isDarkMode ? Colors.white : Colors.black),
      ],
      animationDuration: const Duration(
        milliseconds: 300,
      ),
      animationCurve: Curves.bounceInOut,
      onTap: (index) {
        for (int i = 0; i < itemColors.length; i++) {
          if (i == index) {
            itemColors[i] = Colors.yellow;
          } else {
            itemColors[i] = isDarkMode ? Colors.white : Colors.black;
          }
        }
        setState(() {});


        if (index == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => JobScreen()));
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AllWorkersScreen()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => UploadJobNow()));
        } else if (index == 3) {
          final FirebaseAuth _auth = FirebaseAuth.instance;
          final User? user = _auth.currentUser;
          final String uid = user!.uid;
          Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(
            userID: uid,
          )));
        }
      },
    );
  }
}
