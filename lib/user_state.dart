import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work_matcher_1/Jobs/jobs_screen.dart';

import 'LoginPage/login_screen.dart';

class UserState extends StatefulWidget {
  const UserState({super.key});

  @override
  State<UserState> createState() => _UserStateState();
}

class _UserStateState extends State<UserState> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot)
      {
        if(userSnapshot.data == null){
          print('user is not logged in yet');
          return  Login();
        }
        else if(userSnapshot.hasData)
        {
          print('user is already logged in');
          return JobScreen();
        }
        else if(userSnapshot.connectionState == ConnectionState.waiting)
          {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        return const Scaffold(
          body: Center(
            child: Text('Something went wrong'),
          ),
        );
      },
    );
  }
}
