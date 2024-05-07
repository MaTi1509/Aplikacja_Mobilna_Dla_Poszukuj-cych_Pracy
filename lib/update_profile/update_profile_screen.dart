import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Search/profile_comapny.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      _nameController.text = userData.get('name');
      _emailController.text = userData.get('email');
      _phoneController.text = userData.get('phoneNumber');
      _locationController.text = userData.get('location');
    }
  }

  Future<void> _updateProfileData() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'location': _locationController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Error updating profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    final String uid = _user.uid;
    return Scaffold(
      backgroundColor:
      isDarkMode ? Colors.black : Colors.white, // Set the background color of Scaffold to black
      appBar: AppBar(
        backgroundColor:
        isDarkMode ? Colors.black : Colors.white, // Set the background color of AppBar to black
        centerTitle: true, // Center the title in AppBar
        title: Text(
          'Edit Profile',
          style:
          TextStyle(color: isDarkMode ? Colors.white : Colors.black,), // Set the color of the title text
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: isDarkMode ? Colors.white : Colors.black,
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                color: isDarkMode ? Colors.black : Colors.white,
                padding:
                    EdgeInsets.symmetric(horizontal: 16.0), // Updated padding
                constraints: BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,),
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87,),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black,),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black,),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Name cannot be empty' : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _emailController,
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87,),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black,),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black,),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty || !value.contains('@')
                                  ? 'Enter a valid email'
                                  : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _phoneController,
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,),
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87,),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black,),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black,),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Phone number cannot be empty'
                              : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _locationController,
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,),
                          decoration: InputDecoration(
                            labelText: 'Location',
                            labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87,),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black,),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black,),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Location cannot be empty'
                              : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 190,
                        child: ElevatedButton(
                          onPressed: _updateProfileData,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.yellow[700]!,
                            onPrimary: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 18),
                          ),
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
