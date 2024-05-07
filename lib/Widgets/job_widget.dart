import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:work_matcher_1/Jobs/job_details.dart';
import 'package:work_matcher_1/Services/global_methods.dart';
import 'package:intl/intl.dart'; // Import the intl package for formatting

final Color myCustomYellowShade700 = Color(0xFFFFD600); // Niestandardowy kolor yellow.shade700

class JobWidget extends StatefulWidget {
  final String jobTitle;
  final String jobDescription;
  final String jobId;
  final String uploadedBy;
  final String userImage;
  final String name;
  final bool recruitment;
  final String email;
  final String location;
  final String salary; // Added "salary" field

  const JobWidget({
    required this.jobTitle,
    required this.jobDescription,
    required this.jobId,
    required this.uploadedBy,
    required this.userImage,
    required this.name,
    required this.recruitment,
    required this.email,
    required this.location,
    required this.salary, // Added "salary" field
  });

  @override
  State<JobWidget> createState() => _JobWidgetState();
}

class _JobWidgetState extends State<JobWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _deleteDialog() {
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  if (widget.uploadedBy == _uid) {
                    await FirebaseFirestore.instance
                        .collection('jobs')
                        .doc(widget.jobId)
                        .delete();
                    await Fluttertoast.showToast(
                      msg: 'Job has been deleted',
                      toastLength: Toast.LENGTH_LONG,
                      backgroundColor: Colors.grey,
                      fontSize: 18.0,
                    );
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  } else {
                    GLobalMethod.showErrorDialog(
                        error: "You can't perform this action", ctx: context);
                  }
                } catch (error) {
                  GLobalMethod.showErrorDialog(
                      error: 'This task cannot be deleted', ctx: context);
                } finally {}
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

  String capitalize(String s) {
    if (s == null || s.isEmpty) {
      return s;
    }
    return s[0].toUpperCase() + s.substring(1);
  }

  String formatSalary(double salary) {
    final formatter = NumberFormat('#,###'); // Create a NumberFormat instance
    return formatter.format(salary); // Format the salary amount
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Card(
      color: isDarkMode ? Colors.white10 : Colors.black38,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailsScreen(
                uploadedBy: widget.uploadedBy,
                jobID: widget.jobId,
              ),
            ),
          );
        },
        onLongPress: () {
          _deleteDialog();
        },
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.only(right: 12),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(width: 1),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(widget.userImage),
          ),
        ),
        title: Text(
          capitalize(widget.jobTitle), // Użyj funkcji capitalize do zmiany formatu
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: myCustomYellowShade700, // Użyj niestandardowego koloru
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Salary ',
                    style: TextStyle(
                      color: Colors.white, // White color for "Salary"
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: '${formatSalary(double.parse(widget.salary))} \$', // Add the dollar symbol before widget.salary
                    style: TextStyle(
                      color: myCustomYellowShade700, // Yellow color for ${widget.salary}
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              widget.jobDescription,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: myCustomYellowShade700, // Użyj niestandardowego koloru
        ),
      ),
    );
  }
}
