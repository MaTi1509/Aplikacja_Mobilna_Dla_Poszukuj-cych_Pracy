import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:work_matcher_1/Services/global_methods.dart';
import 'package:work_matcher_1/Services/global_variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  late Animation<double>? _animation;
  late AnimationController _animationController;

  final TextEditingController _fullNameController = TextEditingController(text: '');
  final TextEditingController _emailTextController = TextEditingController(text: '');
  final TextEditingController _passTextController = TextEditingController(text: '');
  final TextEditingController _phoneNumberTextController = TextEditingController(text: '');
  final TextEditingController _locationNumberTextController = TextEditingController(text: '');

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _postionCPFocusNode = FocusNode();

  final _signUpFormKey = GlobalKey<FormState>();
  bool _obscureText = true;
  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? imageUrl;
  String dialCode = '+1';// Default dial code, you can set this to any default value

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _phoneNumberTextController.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _postionCPFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.linear)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((animationStatus) {
        if (animationStatus == AnimationStatus.completed) {
          _animationController.reset();
          _animationController.forward();
        }
      });
    _animationController.forward();
    super.initState();
  }

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Please choose an option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _getFromCamera();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera,
                          color: Colors.yellow.shade700,
                        ),
                      ),
                      Text(
                        'Camera',
                        style: TextStyle(color: Colors.yellow.shade700),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _getFromGallery();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.yellow.shade700,
                        ),
                      ),
                      Text(
                        'Gallery',
                        style: TextStyle(color: Colors.yellow.shade700),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void _submitFormOnSignUp() async {
    final isValid = _signUpFormKey.currentState!.validate();
    if (isValid) {
      if (imageFile == null) {
        GLobalMethod.showErrorDialog(
          error: 'Please pick an image',
          ctx: context,
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailTextController.text.trim().toLowerCase(),
          password: _passTextController.text.trim(),
        );
        final User? user = _auth.currentUser;
        final _uid = user!.uid;
        final ref = FirebaseStorage.instance.ref().child('userImages').child(_uid + '.jpg');
        await ref.putFile(imageFile!);
        imageUrl = await ref.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(_uid).set({
          'id': _uid,
          'name': _fullNameController.text,
          'email': _emailTextController.text,
          'userImage': imageUrl,
          'phoneNumber': dialCode + _phoneNumberTextController.text,
          'location': _locationNumberTextController.text,
          'createdAt': Timestamp.now(),
        });
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        GLobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark; // Check if dark mode is enabled

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: isDarkMode ? Colors.black : Colors.white, // Set the background color based on theme
          ),
          Container(
            color: isDarkMode ? Colors.black54 : Colors.white54, // Set the background color based on theme
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ListView(
                children: [
                  Form(
                    key: _signUpFormKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showImageDialog();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: size.width * 0.24,
                              height: size.width * 0.24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.yellow.shade700,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: imageFile == null
                                    ? Icon(
                                  Icons.camera_alt,
                                  color: Colors.yellow.shade700,
                                  size: 30,
                                )
                                    : Image.file(
                                  imageFile!,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_emailFocusNode),
                          keyboardType: TextInputType.name,
                          controller: _fullNameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field is required';
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Set text color based on theme
                          decoration: InputDecoration(
                              hintText: 'Full Name / Company Name',
                              hintStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Set hint text color based on theme
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Set border color based on theme
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Set border color based on theme
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_passFocusNode),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailTextController,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Please enter a valid email address';
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Set text color based on theme
                          decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Set hint text color based on theme
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Set border color based on theme
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Set border color based on theme
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_phoneNumberFocusNode),
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passTextController,
                          obscureText: !_obscureText,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 7) {
                              return 'Please enter a valid password';
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Set text color based on theme
                          decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                  _obscureText ? Icons.visibility : Icons.visibility_off,
                                  color: isDarkMode ? Colors.white : Colors.black, // Set icon color based on theme
                                ),
                              ),
                              hintText: 'Password',
                              hintStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Set hint text color based on theme
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Set border color based on theme
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Set border color based on theme
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // Phone number field with country code picker
                        Row(
                          children: <Widget>[
                            CountryCodePicker(
                              onChanged: (countryCode) {
                                setState(() {
                                  dialCode = countryCode.dialCode!;
                                });
                              },
                              initialSelection: 'US',
                              favorite: [
                                '+1',
                                'US',
                                '+91',
                                'IN'
                              ],
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              textStyle: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black, // Set text color based on theme
                              ),
                              flagWidth: 30, // Customize the flag width if needed
                            ),
                            Expanded(
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => FocusScope.of(context).requestFocus(_postionCPFocusNode),
                                keyboardType: TextInputType.phone,
                                controller: _phoneNumberTextController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'The field is required';
                                  } else {
                                    return null;
                                  }
                                },
                                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Set text color based on theme
                                decoration: InputDecoration(
                                  hintText: 'Phone number',
                                  hintStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Set hint text color based on theme
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Set border color based on theme
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Set border color based on theme
                                  ),
                                  errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_postionCPFocusNode),
                          keyboardType: TextInputType.text,
                          controller: _locationNumberTextController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'The field is required';
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Set text color based on theme
                          decoration: InputDecoration(
                              hintText: 'Address',
                              hintStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Set hint text color based on theme
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Set border color based on theme
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Set border color based on theme
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              )),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        _isLoading
                            ? Center(
                          child: Container(
                            width: 70,
                            height: 70,
                            child: const CircularProgressIndicator(),
                          ),
                        )
                            : Container(
                          width: 150, // Set the button width here
                          child: MaterialButton(
                            onPressed: () {
                              _submitFormOnSignUp();
                            },
                            color: Colors.yellow.shade700,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Center(
                          child: RichText(
                            text: TextSpan(children: [
                               TextSpan(
                                  text: 'Already have an account?',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black, // Set text color based on theme
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )),
                              const TextSpan(
                                text: "      ",
                              ),
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.canPop(context)
                                        ? Navigator.pop(context)
                                        : null,
                                  text: "Login",
                                  style: TextStyle(
                                    color: Colors.yellow.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )),
                            ]),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
