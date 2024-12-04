import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../utils/colors.dart';
import '../../utils/config.dart';

import 'loginScreen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';

  void _sendPasswordResetEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.sendPasswordResetEmail(email: _email);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $_email'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending password reset email: $e'),
          ),
        );
      }
    }
  }

  // backward navigation function
  Future<bool> _onWillPop() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
    return false; // Prevents the app from exiting
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: height * 0.05),
                  child: Row(children: <Widget>[
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) =>  LoginScreen())),
                      child: Padding(
                        padding: EdgeInsets.only(left: width * 0.04),
                        child: const Icon(
                          Icons.arrow_back_ios_outlined,
                          size: 28,
                          color: Color.fromARGB(255, 12, 63, 112),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        "Reset".tr,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ]),
                ),
                Center(
                  child: Column(
                    children: [
                      Card(
                        elevation: 2, // Adjust the elevation here
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Image(image: AssetImage('assets/logo.png'))
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Reset?".tr),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Enter your email below to send verification to the email"
                                .tr),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border:
                                      OutlineInputBorder(), // Add border to the input field
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email address';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _email = value;
                                  });
                                },
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: 150,
                                child: ElevatedButton(
                                  onPressed:
                                      _sendPasswordResetEmail, // Disable button when loading
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appColorYellow,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    'Send'.tr,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
