import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_matcher_1/Search/search_job.dart';
import 'package:work_matcher_1/Widgets/bottom_nav_bar.dart';
import 'package:work_matcher_1/user_state.dart';

import '../Persistent/persistent.dart';
import '../Widgets/job_widget.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({Key? key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  String? jobCategoryFilter;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  _showTaskCategoriesDialog({required Size size}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            'Job Category',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          content: Container(
            width: size.width * 0.9,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: Persistent.jobCategoryList.length,
              itemBuilder: (ctxx, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      jobCategoryFilter = Persistent.jobCategoryList[index];
                    });
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                    print(
                        'jobCategoryList[index], ${Persistent.jobCategoryList[index]}');
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_right_alt_outlined,
                        color: Colors.yellow[700],
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          Persistent.jobCategoryList[index],
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors
                      .red), // Set the background color for 'Close' button
                  padding: MaterialStateProperty.all(
                      EdgeInsets.all(10)), // Optional: Add padding
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    jobCategoryFilter = null;
                  });
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.all(10)), // Optional: Add padding
                ),
                child: const Text(
                  'Clear Filter',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Persistent persistentObject = Persistent();
    persistentObject.getMyData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white, // Set the background color
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 0),
        appBar: AppBar(
          backgroundColor: isDarkMode ? Colors.black : Colors.white, // Set the app bar background color
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(
                  Icons.filter_list_rounded,
                  size: 25,
                  color: isDarkMode ? Colors.white : Colors.black, // Set the icon color
                ),
                onPressed: () {
                  Scaffold.of(context)
                      .openDrawer(); // Otwórz panel boczny po naciśnięciu ikony filtrów
                },
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search_outlined,
                size: 25,
                color: isDarkMode ? Colors.white : Colors.black, // Set the icon color
              ),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (c) => SearchScreen()));
              },
            )
          ],
        ),
        backgroundColor:
            Colors.transparent, // Set the scaffold background color
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: (jobCategoryFilter == null || jobCategoryFilter!.isEmpty)
              ? FirebaseFirestore.instance
                  .collection('jobs')
                  .where('recruitment', isEqualTo: true)
                  .orderBy('createdAt', descending: false)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('jobs')
                  .where('jobCategory', isEqualTo: jobCategoryFilter)
                  .where('recruitment', isEqualTo: true)
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data?.docs.isNotEmpty == true) {
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return JobWidget(
                      jobTitle: snapshot.data?.docs[index]['jobTitle'],
                      jobDescription: snapshot.data?.docs[index]
                          ['jobDescription'],
                      jobId: snapshot.data?.docs[index]['jobId'],
                      uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                      userImage: snapshot.data?.docs[index]['userImage'],
                      name: snapshot.data?.docs[index]['name'],
                      recruitment: snapshot.data?.docs[index]['recruitment'],
                      email: snapshot.data?.docs[index]['email'],
                      location: snapshot.data?.docs[index]['location'],
                      salary: snapshot.data?.docs[index]['salary'],
                    );
                  },
                );
              } else {
                return Center(
                  child: Text('There are no jobs'),
                );
              }
            }
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.yellow.shade700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
                  child: Text(
                    'Job Category',
                    style: TextStyle(
                      fontSize: 20,
                      color: isDarkMode ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: Persistent.jobCategoryList.length,
                    itemBuilder: (ctxx, index) {
                      final isCategorySelected =
                          Persistent.jobCategoryList[index] ==
                              jobCategoryFilter;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            jobCategoryFilter =
                                Persistent.jobCategoryList[index];
                          });
                          Navigator.pop(context);
                          print(
                              'jobCategoryList[index], ${Persistent.jobCategoryList[index]}');
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons
                                    .circle, // Add a circle icon before the category
                                size: 10,
                                color: isCategorySelected
                                    ? Colors.yellow.shade200
                                    : Colors.black,
                              ),
                              SizedBox(
                                  width:
                                      8), // Add some spacing between the dot and text
                              Text(
                                Persistent.jobCategoryList[index],
                                style: TextStyle(
                                  color: isCategorySelected
                                      ? Colors.yellow.shade200
                                      : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 150,
                      padding: EdgeInsets.only(
                          bottom: 50.0, left: 16.0, right: 16.0),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            jobCategoryFilter = null;
                          });
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.yellow.shade200),
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(10)),
                        ),
                        child: Text(
                          'Clear Filter',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Image.asset(
                    'assets/images/login.png', // Replace with the correct image path
                    width: 150, // Adjust the width as needed
                    height: 150, // Adjust the height as needed
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
