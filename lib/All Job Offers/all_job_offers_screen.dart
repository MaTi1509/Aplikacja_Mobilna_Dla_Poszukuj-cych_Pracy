import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widgets/job_widget.dart';
import '../Search/profile_comapny.dart';

class AllJobsOffersScreen extends StatefulWidget {
  const AllJobsOffersScreen({Key? key}) : super(key: key);

  @override
  _AllJobsOffersScreenState createState() => _AllJobsOffersScreenState();
}

class _AllJobsOffersScreenState extends State<AllJobsOffersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> jobOffers = [];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    fetchJobOffers();
  }

  Future<void> fetchJobOffers() async {
    final jobOffersSnapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .where('uploadedBy', isEqualTo: _user.uid)
        .get();

    setState(() {
      jobOffers = jobOffersSnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String uid = _user.uid; // Get the current user's UID

    return Scaffold(
      backgroundColor:
          Colors.black, // Set the background color of Scaffold to black
      appBar: AppBar(
        backgroundColor:
            Colors.black, // Set the background color of AppBar to black
        centerTitle: true, // Center the title in AppBar
        title: Text(
          'My Job Offers',
          style:
              TextStyle(color: Colors.white), // Set the color of the title text
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfileScreen(userID: uid), // Navigate to ProfileScreen
              ),
            );
          },
        ),
      ),
      body: jobOffers.isEmpty
          ? Center(
              child: Text('No job offers found',
                  style: TextStyle(color: Colors.white)))
          : ListView.builder(
              itemCount: jobOffers.length,
              itemBuilder: (context, index) {
                final jobOffer =
                    jobOffers[index].data() as Map<String, dynamic>;
                return JobWidget(
                  jobTitle: jobOffer['jobTitle'],
                  jobDescription: jobOffer['jobDescription'],
                  jobId: jobOffer['jobId'],
                  uploadedBy: jobOffer['uploadedBy'],
                  userImage: jobOffer['userImage'],
                  name: jobOffer['name'],
                  recruitment: jobOffer['recruitment'],
                  email: jobOffer['email'],
                  location: jobOffer['location'],
                  salary: jobOffer['salary'], // Added "salary" field
                );
              },
            ),
    );
  }
}
