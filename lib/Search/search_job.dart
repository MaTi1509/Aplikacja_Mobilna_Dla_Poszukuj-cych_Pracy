import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_matcher_1/Jobs/jobs_screen.dart';
import '../Widgets/job_widget.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = '';

  Widget _buildSearchField() {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: InputDecoration(
        hintText: 'Search for jobs...',
        prefixIcon: Icon(
          Icons.search,
          color: Colors.yellow.shade700,
        ),
        border: InputBorder.none,
        hintStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return <Widget>[
      IconButton(
        icon: Icon(Icons.clear),
        color: isDarkMode ? Colors.white : Colors.black,
        onPressed: () {
          _clearSearchQuery();
        },
      ),
    ];
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery('');
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery.toLowerCase(); // Normalize to lowercase
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> createJobSearchStream(String query) {
    var collection = FirebaseFirestore.instance.collection('jobs');
    if (query.isNotEmpty) {
      return collection
          .where('jobTitle', isGreaterThanOrEqualTo: query)
          .where('jobTitle', isLessThanOrEqualTo: query + '\uf8ff')
          .where('recruitment', isEqualTo: true)
          .snapshots();
    } else {
      return collection.where('recruitment', isEqualTo: true).snapshots();
    }
  }

  String capitalize(String s) {
    if (s.isEmpty) {
      return s;
    }
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => JobScreen()));
            },
            icon: Icon(Icons.arrow_back_outlined),
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          title: _buildSearchField(),
          actions: _buildActions(),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: createJobSearchStream(searchQuery),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.data?.docs.isNotEmpty == true) {
              return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  var doc = snapshot.data?.docs[index];
                  return JobWidget(
                    jobTitle: capitalize(doc['jobTitle']),
                    jobDescription: doc['jobDescription'],
                    jobId: doc['jobId'],
                    uploadedBy: doc['uploadedBy'],
                    userImage: doc['userImage'],
                    name: doc['name'],
                    recruitment: doc['recruitment'],
                    email: doc['email'],
                    location: doc['location'],
                    salary: doc['salary'],
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  'No jobs found',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
