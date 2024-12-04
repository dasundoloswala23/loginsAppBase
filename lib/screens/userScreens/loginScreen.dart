import 'dart:async';
import 'dart:io' show Platform;
import 'package:baseproject/screens/homeScreen/homeScreen.dart';
import 'package:baseproject/screens/userScreens/resetPasswordScreen.dart';
import 'package:baseproject/screens/userScreens/signUpScreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';


import '../../provider/internet_provider.dart';
import '../../provider/sign_in_provider.dart';
import '../../utils/next_Screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../Provider/user_model.dart';
import '../../utils/colors.dart';
import '../../utils/snack_bar.dart';


class LoginScreen extends StatefulWidget {
  String? screen ;
  String? screenId ;
   LoginScreen({Key? key, this.screen , this.screenId }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // requestNotificationPermissionWithOutOpenSetting(context);
    // requestPermission(); //firebase_messaging
    // checkGps();
  }

  //firebase
  final _auth = FirebaseAuth.instance;

  //form key
  final _formKey = GlobalKey<FormState>();

  //editing controller

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RoundedLoadingButtonController googleController =
  RoundedLoadingButtonController();
  final RoundedLoadingButtonController appleController =
  RoundedLoadingButtonController();

  // backward navigation function
  Future<bool> _onWillPop() async {
    // nextScreen(context,Navigation(initialIndex: 0) ) ;
  return false; // Prevents the app from exiting
  }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    //email field
    final emailField = SizedBox(
      width: width * 0.85,
      child: TextFormField(
          autofocus: false,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value!.isEmpty) {
              return ("Please Enter Your Email");
            }
            //reg expression for email validation
            if (!RegExp(
                "^[a-zA-Z0-9.a-zA-Z0-9.!#%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value)) {
              return ("Please Enter Valid Email" );
            }
            return null;
          },
          onSaved: (value) {
            emailController.text = value!;
          },
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.mail),
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            labelText: 'Email',
            // hintText: "Email".tr,
            labelStyle: GoogleFonts.getFont(
              'Poppins', // Replace with your desired Google Font
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.black12,
              ),
            ),
          )),
    );

    //password field
    final passwordField = SizedBox(
      width: width * 0.85,
      child: TextFormField(
        autofocus: false,
        controller: passwordController,
        obscureText: true,
        validator: (value) {
          RegExp regex = RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ("Password Is Required For Login");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password");
          }
        },
        onSaved: (value) {
          passwordController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.visibility),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          labelText: 'Password',
          // hintText: "Password".tr,
          labelStyle: GoogleFonts.getFont(
            'Poppins', // Replace with your desired Google Font
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.black12,
            ),
          ),
        ),
      ),
    );

    final loginButton = SizedBox(
      width: width * 0.85,
      height: height * 0.069,
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(25),
        color:  HexColor('2596be'),
        child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            FirebaseAnalytics.instance
                .logEvent(name: 'loginScreen_email_signin');
            signIn(emailController.text, passwordController.text);
          },
          child: Text(
            "Login" ,

            // textScaleFactor: 1.0,
            style: GoogleFonts.getFont(
              'Poppins', // Replace with your desired Google Font
              // textAlign: TextAlign.center,
              textStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
    return  WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: width * 0.14,
                            right: width * 0.15,
                            bottom: height * 0.05,
                            top: height * 0.15),
                        child: SizedBox(
                          height: height * 0.10,
                          child: const Image(
                            image: AssetImage('assets/logo.png'),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 0.40,
                      ),
                      Center(
                        child: Text(
                          " Sign In" ,
                          style: GoogleFonts.getFont(
                              'Poppins', // Replace with your desired Google Font
                              fontWeight: FontWeight.w600,
                              fontSize: 30),
                        ),
                      ),


                      const SizedBox(height: 25),
                      SizedBox(height: height * 0.008),
                      emailField,
                      SizedBox(height: height * 0.04),
                      passwordField,
                      SizedBox(height: height * 0.05),
                      loginButton,
                      SizedBox(height: height * 0.02),
                      const SizedBox(height: 5),

                      Text(
                        "or" ,
                        style: GoogleFonts.getFont(
                            'Poppins', // Replace with your desired Google Font
                            fontWeight: FontWeight.w400,
                            fontSize: 18),
                      ),
                      SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          SizedBox(
                            width: 50,
                            child: RoundedLoadingButton(
                              onPressed: () {
                                handleGoogleSignIn();
                                FirebaseAnalytics.instance
                                    .logEvent(name: 'loginScreen_google_signin');
                              },
                              controller: googleController,
                              successColor: Colors.white,
                              // width: width * 19,
                              elevation: 08,
                              borderRadius: 25,
                              color: Colors.white,
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: const Wrap(
                                children: [
                                  // Image.asset(
                                  //   'assets/images/googleicons.png', // Add the path to your Google icon image
                                  //   height: 25,
                                  //   width: 25,
                                  // )
                                  Icon(
                                    FontAwesomeIcons.google,
                                    size: 25,

                                    //adding font awesome icons
                                  ),
                                  // SizedBox(
                                  //   width: width * 0.5,
                                  // ),
                                  // Text(
                                  //   'SignIn With Google'.tr,
                                  //   style: TextStyle(
                                  //       color: Colors.white,
                                  //       fontSize: 20,
                                  //       fontWeight: FontWeight.w500),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 50,
                            child: RoundedLoadingButton(
                              onPressed: () {
                                handleAppleSignIn();
                                FirebaseAnalytics.instance
                                    .logEvent(name: 'loginScreen_apple_signin');
                              },
                              controller: appleController,
                              successColor: Colors.white,
                              // width: width * 19,
                              elevation: 08,
                              borderRadius: 25,
                              color: Colors.white,
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: const Wrap(
                                children: [
                                  // Image.asset(
                                  //   'assets/images/googleicons.png', // Add the path to your Google icon image
                                  //   height: 25,
                                  //   width: 25,
                                  // )
                                  Icon(
                                    FontAwesomeIcons.apple,
                                    size: 25,

                                    //adding font awesome icons
                                  ),
                                  // SizedBox(
                                  //   width: width * 0.5,
                                  // ),
                                  // Text(
                                  //   'SignIn With Google'.tr,
                                  //   style: TextStyle(
                                  //       color: Colors.white,
                                  //       fontSize: 20,
                                  //       fontWeight: FontWeight.w500),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              text: "Don’t have an account? " ,
                              style: GoogleFonts.getFont('Poppins',
                                  fontSize: 14, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Signup' ,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                          builder: (context) =>
                                           SignUpScreen())),
                                    style: TextStyle(
                                        color:  appColorYellow,
                                        decoration: TextDecoration.underline,
                                        height: 1.2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.005),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              text: "Forgot Password?" ,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                    builder: (context) =>
                                    const ResetPasswordScreen())),
                              style: GoogleFonts.getFont(
                                'Poppins',
                                fontSize: 14,
                                color: HexColor('2596be'),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
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

  Future handleAppleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();
    appleController.reset();
    if (ip.hasInternet == false) {
      openSnackbar(context, 'Check your Internet connection', Colors.red);
      appleController.reset();
    } else {
      await sp.signInWithAppleID().then((value) {
        if (sp.hasError == true) {
          openSnackbar(context, sp.errorCode.toString(), Colors.black);
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid!).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                appleController.success();
                handleAfterSignIn();
              })));
            } else {
              // user does not exist
              sp.saveDataToFirestore().then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                // save user location
                // saveUserLocation();
                appleController.success();
                handleAfterSignIn();
              })));
            }
          });
        }
      });
    }
    //login function
  }

  // handling google sign in
  Future handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackbar(context, 'Check your Internet connection', Colors.red);
      googleController.reset();
    } else {
      await sp.signInWithGoogle().then((value) {
        if (sp.hasError == true) {
          openSnackbar(context, sp.errorCode.toString(), Colors.white);
          googleController.reset();
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid!).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                googleController.success();
                handleAfterSignIn();
              })));
            } else {
              // user does not exist
              sp.saveDataToFirestore().then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                // save user location
                // saveUserLocation();
                googleController.success();
                handleAfterSignIn();
              })));
            }
          });
        }
      });
    }
    //login function
  }

  //handle After SignIn
  handleAfterSignIn() {
    print("widget.screen ${widget.screen}");
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      if(widget.screen == null ){
        nextScreenReplace(context, HomeScreen());
      }else if(widget.screen == 'WishlistScreen'){
        nextScreenReplace(context, HomeScreen());
      }

    });
  }

  void signIn(String email, String password) async {
    final _auth = FirebaseAuth.instance;
    final sp = context.read<SignInProvider>();

    if (_formKey.currentState!.validate()) {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        // Fetch user data from Firestore and save it in provider
        await sp.getUserDataFromFirestore(value.user!.uid);
        sp.setSignIn(); // Set the sign-in status in provider
        handleAfterSignIn();
        Fluttertoast.showToast(msg: "Login Successful");
      }).catchError((e) {
        if (e is FirebaseAuthException && e.code == 'wrong-password') {
          Fluttertoast.showToast(msg: "Incorrect password");
        } else {
          Fluttertoast.showToast(msg: e.message ?? "Login failed");
        }
      });
    }
  }


  //user location
  bool servicestatus = false;
  bool haspermission = false;
  // late LocationPermission permission;
  // late Position position;
  // late StreamSubscription<Position> positionStream;
  // String long = "", lat = "";
  //
  // String street = "notload"; // Initialize with a loading message
  // String city = "notload"; // Initialize with a loading message
  // String province = "notload"; // Initialize with a loading message

  // checkGps() async {
  //   servicestatus = await Geolocator.isLocationServiceEnabled();
  //   if (servicestatus) {
  //     permission = await Geolocator.checkPermission();
  //
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         print('Location permissions are denied');
  //       } else if (permission == LocationPermission.deniedForever) {
  //         print('Location permissions are permanently denied');
  //       } else {
  //         haspermission = true;
  //       }
  //     } else {
  //       haspermission = true;
  //     }
  //
  //     if (haspermission) {
  //       setState(() {
  //         // Refresh the UI
  //       });
  //
  //       // getLocation();
  //     }
  //   } else {
  //     print('GPS Service is not enabled, turn on GPS location');
  //   }
  //
  //   setState(() {
  //     // Refresh the UI
  //   });
  // }

  // getLocation() async {
  //   position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //
  //   // Fetch the address using reverse geocoding
  //   List<Placemark> placemarks =
  //   await placemarkFromCoordinates(position.latitude, position.longitude);
  //
  //   setState(() {
  //     long = position.longitude.toString();
  //     lat = position.latitude.toString();
  //
  //     if (placemarks.isNotEmpty) {
  //       Placemark placemark = placemarks.first;
  //       // Construct the address string from the placemark information
  //       String street = "${placemark.street}";
  //       String city = "   ${placemark.subLocality} ,${placemark.locality}";
  //       String province =
  //           "  ${placemark.administrativeArea} , ${placemark.subAdministrativeArea} ,${placemark.country}  ";
  //       // Update the address state variable
  //       this.street = street;
  //       this.city = city;
  //       this.province = province;
  //     } else {
  //       // No address found
  //       this.street = "Address not available";
  //       this.city = "Address not available";
  //       this.province = "Address not available";
  //     }
  //   });
  //
  //   LocationSettings locationSettings = LocationSettings(
  //     accuracy: LocationAccuracy.high,
  //     distanceFilter: 100,
  //   );
  //
  //   positionStream = Geolocator.getPositionStream(
  //     locationSettings: locationSettings,
  //   ).listen((Position position) {
  //     // Similar to above, fetch and update the address when a new position is received
  //   });
  // }

  // Future saveUserLocation() async {
  //   User? user = _auth.currentUser;
  //   final sp = context.read<SignInProvider>();
  //
  //   UserModel userModel = UserModel();
  //   FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  //   await firebaseFirestore.collection("locationUsers").doc(user?.uid).set({
  //     "name": sp.displayName,
  //     "email": sp.email,
  //     'longitude': long,
  //     'latitude': lat,
  //     "street": street,
  //     "city": city,
  //     "province": province,
  //   });
  // }
}