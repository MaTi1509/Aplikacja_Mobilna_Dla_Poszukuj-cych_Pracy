import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:work_matcher_1/ForgotPassword/forgot_password_screen.dart';
import 'package:work_matcher_1/Signup%20Page/signup_screen.dart';
import '../Services/global_methods.dart';
import '../Services/global_variables.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailTextController = TextEditingController(text: '');
  final TextEditingController _passTextControler = TextEditingController(text: '');

  final FocusNode _passFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscureText = true; // Set this to true initially
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _loginFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailTextController.dispose();
    _passTextControler.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  void _submitFormOnLogin() async {
    final isValid = _loginFormKey.currentState!.validate();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailTextController.text.trim().toLowerCase(),
          password: _passTextControler.text.trim(),
        );
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        GLobalMethod.showErrorDialog(error: error.toString(), ctx: context);
        print('error occurred $error');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        color: isDarkMode ? Colors.black : Colors.white, // Set background color based on theme
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 80, right: 80),
                child: Image.asset('assets/images/login.png'),
              ),
              const SizedBox(
                height: 15,
              ),
              Form(
                key: _loginFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(_passFocusNode),
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailTextController,
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid Email address';
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black, // Set text color based on theme
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black, // Set hint text color based on theme
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black, // Set border color based on theme
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black, // Set border color based on theme
                          ),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      focusNode: _passFocusNode,
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passTextControler,
                      obscureText: _obscureText, // Use the _obscureText variable
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'Please enter a valid password';
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black, // Set text color based on theme
                      ),
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: isDarkMode ? Colors.white : Colors.black, // Set icon color based on theme
                          ),
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black, // Set hint text color based on theme
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black, // Set border color based on theme
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black, // Set border color based on theme
                          ),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassword()));
                        },
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black, // Set text color based on theme
                            fontSize: 17,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 150, // Adjust the Container width as needed
                      child: MaterialButton(
                        onPressed: _submitFormOnLogin,
                        color: Colors.yellow.shade700, // Yellow button color
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.black, // Text color on button
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
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
                              text: 'Do not have an account?',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black, // Set text color based on theme
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),
                          TextSpan(text: '      '),
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () =>
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp())),
                            text: 'Sign Up',
                            style: TextStyle(
                              color: Colors.yellow.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ]),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
