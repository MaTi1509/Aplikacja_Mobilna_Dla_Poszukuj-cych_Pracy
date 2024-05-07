import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:work_matcher_1/Widgets/bottom_nav_bar.dart';

import '../Widgets/all_companies_widget.dart';

class AllWorkersScreen extends StatefulWidget {
  const AllWorkersScreen({super.key});

  @override
  State<AllWorkersScreen> createState() => _AllWorkersScreenState();
}

class _AllWorkersScreenState extends State<AllWorkersScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = '';

  Widget _buildSearchField() {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: InputDecoration(
        hintText: 'Search for companies...',
        prefixIcon: Icon(
          Icons.search, // Add the search icon here
          color: Colors.yellow.shade700,
        ),
        border: InputBorder.none,
        hintStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black,),
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

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return SafeArea(
      top: false, // Exclude top area from padding
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.white,
        ),
        child: Scaffold(
          bottomNavigationBar: BottomNavigationBarForApp(
            indexNum: 1,
          ),
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            automaticallyImplyLeading: false,
            title: _buildSearchField(),
            actions: _buildActions(),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Something went wrong',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.active) {
                var filteredDocs = snapshot.data!.docs
                    .where((doc) =>
                    doc['name'].toString().toLowerCase().startsWith(searchQuery))
                    .toList();

                if (filteredDocs.isNotEmpty) {
                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (BuildContext context, int index) {
                      var doc = filteredDocs[index];
                      return AllWorkersWidget(
                        userID: doc['id'],
                        userName: doc['name'],
                        userEmail: doc['email'],
                        phoneNumber: doc['phoneNumber'],
                        userImageUrl: doc['userImage'],
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('No users found', style: TextStyle(color: Colors.black38)),
                  );
                }
              }
              return Container(); // Empty container for other states
            },
          ),
        ),
      ),
    );
  }
}
