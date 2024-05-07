import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:work_matcher_1/Widgets/comments_widget.dart';

import '../Services/global_methods.dart';
import '../Services/global_variables.dart';
import 'jobs_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final String uploadedBy;
  final String jobID;

  const JobDetailsScreen({
    required this.uploadedBy,
    required this.jobID,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  @override
  void initState() {
    super.initState();
    getJobData();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;
  String? authorName;
  String? userImageUrl;
  String? jobCategory;
  String? jobDescription;
  String? jobTitle;
  bool? recruitment;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? postedDate;
  String? deadlineDate;
  String? locationCompany = '';
  String? email = '';
  int applicants = 0;
  bool isDeadlineAvailable = false;
  bool showComment = false;

  void getJobData() async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uploadedBy)
          .get();

      if (!userDoc.exists) {
        throw Exception('User document does not exist.');
      }

      final DocumentSnapshot jobDoc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobID)
          .get();

      if (!jobDoc.exists) {
        throw Exception('Job document does not exist.');
      }

      setState(() {
        final Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;
        final Map<String, dynamic> jobData =
            jobDoc.data() as Map<String, dynamic>;

        authorName = userData['name'];
        userImageUrl = userData['userImage'];

        jobTitle = jobData['jobTitle'];
        jobDescription = jobData['jobDescription'];
        recruitment = jobData['recruitment'];
        email = jobData['email'];
        locationCompany = jobData['location'];
        applicants = jobData['applicants'];
        deadlineDate = jobData['deadlineDate'];

        final Timestamp postedTimestamp = jobData['createdAt'];
        final Timestamp deadlineTimestamp = jobData['deadlineDateTimeStamp'];

        if (postedTimestamp != null) {
          final DateTime postDate = postedTimestamp.toDate();
          postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
        }

        if (deadlineTimestamp != null) {
          final DateTime deadlineDate = deadlineTimestamp.toDate();
          isDeadlineAvailable = deadlineDate.isAfter(DateTime.now());
        }
      });
    } catch (e) {
      print('Error getting job data: $e');
    }
  }

  Widget dividerWidget() {
    return Column(
      children: [
        SizedBox(height: 10),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  applyForJob() {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=Applying for $jobTitle&body=Hello, please attach Resume CV file',
    );
    final url = params.toString();
    launch(url);
    addNewApplicant();
  }

  void addNewApplicant() async {
    var docRef =
        FirebaseFirestore.instance.collection('jobs').doc(widget.jobID);
    docRef.update({
      'applicants': applicants + 1,
    });

    Navigator.pop(context);
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
            icon: Icon(
              Icons.close,
              size: 40,
              color: Colors.yellow.shade700,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => JobScreen()));
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: isDarkMode ? Colors.white10 : Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            jobTitle == null
                                ? 'Job offer description'
                                : jobTitle!,
                            maxLines: 3,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape
                                    .circle, // Zmieniamy shape na circle
                                image: DecorationImage(
                                  image: NetworkImage(
                                    userImageUrl == null
                                        ? 'https://img.freepik.com/premium-vector/user-profile-icon-flat-style-member-avatar-vector-illustration-isolated-background-human-permission-sign-business-concept_157943-15752.jpg'
                                        : userImageUrl!,
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName == null ? '' : authorName!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    locationCompany!,
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              applicants.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 6),
                            Center(
                              child: Text(
                                'Applicants',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.how_to_reg_sharp,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        FirebaseAuth.instance.currentUser!.uid !=
                                widget.uploadedBy
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  dividerWidget(),
                                  Center(
                                    child: Text(
                                      'Recruitment',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            User? user = _auth.currentUser;
                                            final _uid = user!.uid;
                                            if (_uid == widget.uploadedBy) {
                                              try {
                                                FirebaseFirestore.instance
                                                    .collection('jobs')
                                                    .doc(widget.jobID)
                                                    .update(
                                                        {'recruitment': true});
                                              } catch (error) {
                                                GLobalMethod.showErrorDialog(
                                                  error:
                                                      'Action cannot be performed',
                                                  ctx: context,
                                                );
                                              }
                                            } else {
                                              GLobalMethod.showErrorDialog(
                                                error:
                                                    'You cannot perform this action',
                                                ctx: context,
                                              );
                                            }
                                            getJobData();
                                          },
                                          child: Text(
                                            'ON',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          )),
                                      Opacity(
                                        opacity: recruitment == true ? 1 : 0,
                                        child: Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 40,
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            User? user = _auth.currentUser;
                                            final _uid = user!.uid;
                                            if (_uid == widget.uploadedBy) {
                                              try {
                                                FirebaseFirestore.instance
                                                    .collection('jobs')
                                                    .doc(widget.jobID)
                                                    .update(
                                                        {'recruitment': false});
                                              } catch (error) {
                                                GLobalMethod.showErrorDialog(
                                                  error:
                                                      'Action cannot be performed',
                                                  ctx: context,
                                                );
                                              }
                                            } else {
                                              GLobalMethod.showErrorDialog(
                                                error:
                                                    'You cannot perform this action',
                                                ctx: context,
                                              );
                                            }
                                            getJobData();
                                          },
                                          child: Text(
                                            'OFF',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          )),
                                      Opacity(
                                        opacity: recruitment == false ? 1 : 0,
                                        child: const Icon(
                                          Icons.highlight_off_outlined,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                        dividerWidget(),
                        Center(
                          child: Text(
                            'Job Description',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          jobDescription == null ? '' : jobDescription!,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        dividerWidget(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Card(
                  color: isDarkMode ? Colors.white10 : Colors.black54,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            isDeadlineAvailable
                                ? 'Actively Recruiting, Send CV:'
                                : 'Deadline passed away.',
                            style: TextStyle(
                              color: isDeadlineAvailable
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Warunek sprawdzający, czy termin zgłoszeń nie minął
                        if (isDeadlineAvailable)
                          Center(
                            child: MaterialButton(
                              onPressed: () {
                                applyForJob();
                              },
                              color: Colors.yellow.shade700,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text(
                                  'Easy Apply Now',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Uploaded on: ',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              postedDate == null ? '' : postedDate!,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Deadline date: ',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              deadlineDate == null ? '' : deadlineDate!,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        dividerWidget(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Card(
                  color: isDarkMode ? Colors.white10 : Colors.black54,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: Duration(
                            milliseconds: 500,
                          ),
                          child: _isCommenting
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      flex: 3,
                                      child: TextField(
                                        controller: _commentController,
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                        maxLength: 200,
                                        keyboardType: TextInputType.text,
                                        maxLines: 6,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.pink),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: MaterialButton(
                                              onPressed: () async {
                                                if (_commentController
                                                        .text.length <
                                                    7) {
                                                  GLobalMethod.showErrorDialog(
                                                    error:
                                                        'Comment cannot be less than 7 characters',
                                                    ctx: context,
                                                  );
                                                } else {
                                                  final _generatedId =
                                                      const Uuid().v4();
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('jobs')
                                                      .doc(widget.jobID)
                                                      .update({
                                                    'jobComments':
                                                        FieldValue.arrayUnion([
                                                      {
                                                        'userId': FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid,
                                                        'commentId':
                                                            _generatedId,
                                                        'name': name,
                                                        'userImageUrl':
                                                            userImage,
                                                        'commentBody':
                                                            _commentController
                                                                .text,
                                                        'time': Timestamp.now(),
                                                      }
                                                    ]),
                                                  });
                                                  await Fluttertoast.showToast(
                                                    msg:
                                                        'Your comment has been added',
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    backgroundColor:
                                                        Colors.grey,
                                                    fontSize: 18.0,
                                                  );
                                                  _commentController.clear();
                                                }
                                                setState(() {
                                                  showComment = true;
                                                });
                                              },
                                              color: Colors.yellow.shade700,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Post',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _isCommenting = !_isCommenting;
                                                showComment = false;
                                              });
                                            },
                                            child: Text('Cancel'),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min, // Ustawia rozmiar Row na minimalny, potrzebny do obejmowania tekstu i ikony
                                      children: <Widget>[
                                         // Dodaje odstęp między tekstem a ikoną
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isCommenting = !_isCommenting;
                                            });
                                          },
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.yellow.shade700,
                                            size: 40,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isCommenting = !_isCommenting;
                                            });
                                          },
                                          child: Text(
                                            "Click to add", // Tekst, który chcesz dodać po lewej stronie ikony
                                            style: TextStyle(
                                              color: Colors.yellow.shade700, // Możesz dostosować styl tekstu
                                              // Dodatkowe style tekstu, jeśli są potrzebne
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isCommenting = !_isCommenting;
                                            });
                                          },
                                          child: Text(
                                            "comment", // Tekst, który chcesz dodać po lewej stronie ikony
                                            style: TextStyle(
                                              color: Colors.yellow.shade700, // Możesz dostosować styl tekstu
                                              // Dodatkowe style tekstu, jeśli są potrzebne
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisSize: MainAxisSize.min, // Ustawia rozmiar Row na minimalny, potrzebny do obejmowania ikony i tekstu
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showComment = true;
                                            });
                                          },
                                          child: Icon(
                                            Icons.keyboard_double_arrow_down,
                                            color: Colors.yellow.shade700,
                                            size: 40,
                                          ),
                                        ),
                                        SizedBox(width: 1), // Dodaje odstęp między ikoną a tekstem
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showComment = true;
                                            });
                                          },
                                          child: Text(

                                            "Click to see", // Tekst, który chcesz dodać
                                            style: TextStyle(
                                              color: Colors.yellow.shade700, // Możesz dostosować styl tekstu
                                              // Dodatkowe style tekstu, jeśli są potrzebne
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showComment = true;
                                            });
                                          },
                                          child: Text(

                                            "comments", // Tekst, który chcesz dodać
                                            style: TextStyle(
                                              color: Colors.yellow.shade700, // Możesz dostosować styl tekstu
                                              // Dodatkowe style tekstu, jeśli są potrzebne
                                            ),
                                          ),
                                        ),
                                      ],
                                    )

                                  ],
                                ),
                        ),
                        showComment == false
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.all(16),
                                child: FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('jobs')
                                      .doc(widget.jobID)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else {
                                      if (snapshot.data == null) {
                                        return const Center(
                                            child: Text(
                                                'No Comment for this job'));
                                      }
                                    }
                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return CommentWidget(
                                          commentId:
                                              snapshot.data!['jobComments']
                                                  [index]['commentId'],
                                          commenterId:
                                              snapshot.data!['jobComments']
                                                  [index]['userId'],
                                          commenterName:
                                              snapshot.data!['jobComments']
                                                  [index]['name'],
                                          commentBody:
                                              snapshot.data!['jobComments']
                                                  [index]['commentBody'],
                                          commenterImageUrl:
                                              snapshot.data!['jobComments']
                                                  [index]['userImageUrl'],
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return const Divider(
                                          thickness: 1,
                                          color: Colors.grey,
                                        );
                                      },
                                      itemCount:
                                          snapshot.data!['jobComments'].length,
                                    );
                                  },
                                ),
                              )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
