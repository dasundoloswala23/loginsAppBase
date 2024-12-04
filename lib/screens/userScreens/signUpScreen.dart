import 'dart:async';

import 'package:baseproject/screens/homeScreen/homeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

// import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../provider/sign_in_provider.dart';
import '../../provider/user_model.dart';
import '../../utils/config.dart';
import '../../utils/next_Screen.dart';

import 'loginScreen.dart';

class SignUpScreen extends StatefulWidget {
  String? screen;
      String? screenId ;
   SignUpScreen({Key? key, this.screen, this.screenId}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;

  //our form key
  final _formkey = GlobalKey<FormState>();
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController =
  RoundedLoadingButtonController();

  //editing Controller
  final nameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();

  // Snackbar for showing an error
  void showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(content: Text(snackText), duration: d);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //user location
  bool servicestatus = false;
  bool haspermission = false;
  // late LocationPermission permission;
  // late Position position;
  // late StreamSubscription<Position> positionStream;
  String long = "", lat = "";

  String street = "notload"; // Initialize with a loading message
  String city = "notload"; // Initialize with a loading message
  String province = "notload"; // Initialize with a loading message
  @override
  void initState() {
    // checkGps();
    super.initState();
  }

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
  //       getLocation();
  //     }
  //   } else {
  //     print('GPS Service is not enabled, turn on GPS location');
  //   }
  //
  //   setState(() {
  //     // Refresh the UI
  //   });
  // }
  //
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

  Future<void> signUpUser() async {
    final formState = _formkey.currentState;
    if (formState!.validate()) {
      formState.save();
      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
            email: emailEditingController.text.trim(),
            password: passwordEditingController.text)
            .catchError((error) {
          String errorMessage = error.toString();
          showSnackBar(errorMessage.toString(), Duration(seconds: 4));
        });

        User? user = userCredential.user;

        if (user != null) {
          final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

          await usersCollection.doc(user.uid).set({
            'name': nameEditingController.text.trim(),
            'email': emailEditingController.text.trim(),
          });

          await usersCollection.doc(user.uid).update({'uid': user.uid});

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      } catch (e) {
        showSnackBar(e!.toString(), Duration(seconds: 4));
      }
    }
  }

//////// added
  Future<void> linkWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final User user = _auth.currentUser!;

      final UserCredential userCredential =
      await user.linkWithCredential(credential);

      final User linkedUser = userCredential.user!;

      print('Account linking successful for ${linkedUser.email}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        print('The account already exists with a different credential.');
      } else {
        print('Error linking account: $e');
      }
    } catch (e) {
      print('Error linking account: $e');
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

//////// added
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    double width = MediaQuery.of(context).size.width;
    // name field
    final FocusNode nameFocusNode = FocusNode();
    final nameField = SizedBox(
      width: width * 0.85,
      child: StatefulBuilder(
        builder: (context, setState) {
          return TextFormField(
            autofocus: false,
            controller: nameEditingController,
            keyboardType: TextInputType.name,
            focusNode: nameFocusNode,
            validator: (value) {
              if (value!.isEmpty) {
                return ("PleaseEnterYourName".tr);
              } else if (value.length < 3) {
                return ("NameShouldBeAtLeast3Characters".tr);
              }
              return null;
            },
            onSaved: (value) {
              nameEditingController.text = value!;
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.person),
              contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
              labelText: 'Name',
              // hintText: "Name".tr,
              labelStyle: GoogleFonts.getFont(
                'Poppins', // Replace with your desired Google Font
              ),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: nameFocusNode.hasFocus ? Colors.blue : Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: nameFocusNode.hasFocus ? Colors.blue : Colors.grey,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
            ),
          );
        },
      ),
    );

    //email  field
    final emailField = SizedBox(
      width: width * 0.85,
      child: TextFormField(
          autofocus: false,
          controller: emailEditingController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value!.isEmpty) {
              return ("PleaseEnterYourEmail".tr);
            }
            //reg expression for email validation
            if (!RegExp(
                "^[a-zA-Z0-9.a-zA-Z0-9.!#%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value)) {
              return ("PleaseEnterValidEmail".tr);
            }
            return null;
          },
          onSaved: (value) {
            emailEditingController.text = value!;
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          )),
    );
    //password  field
    final passwordField = SizedBox(
      width: width * 0.85,
      child: TextFormField(
        autofocus: false,
        controller: passwordEditingController,
        obscureText: true,
        validator: (value) {
          RegExp regex = RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ("Passwordisrequiredforlogin".tr);
          }
          if (!regex.hasMatch(value)) {
            return ("EnterValidPassword".tr);
          }
          return null;
        },
        onSaved: (value) {
          passwordEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.visibility),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          labelText: 'Password',
          // hintText: "Password".tr,
          labelStyle: GoogleFonts.getFont(
            'Poppins', // Replace with your desired Google Font
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ); //confirm Password  field
    final confirmPasswordField = SizedBox(
      width: width * 0.85,
      child: TextFormField(
          autofocus: false,
          controller: confirmPasswordEditingController,
          obscureText: true,
          validator: (value) {
            if (confirmPasswordEditingController.text !=
                passwordEditingController.text) {
              return ("Password don't match".tr);
            }
            return null;
          },
          onSaved: (value) {
            confirmPasswordEditingController.text = value!;
          },
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
          ],
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.visibility),
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            labelText: 'Confirm Password',
            // hintText: "Confirm Password".tr,
            labelStyle: GoogleFonts.getFont(
              'Poppins', // Replace with your desired Google Font
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          )),
    );
    //signUp button
    final signUpButton = SizedBox(
      width: width * 0.85,
      height: height * 0.069,
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(25),
        color: HexColor('2596be'),
        child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            signUp(emailEditingController.text, passwordEditingController.text,
                nameEditingController.text);
          },
          child: Text(
            "Sign Up".tr,
            textScaleFactor: 1.0,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        leading: GestureDetector(
                          child: const Icon(
                            Icons.arrow_back_ios_new_sharp,
                            color: Colors.black,
                            size: 24.0,
                          ),
                          onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>  LoginScreen())),
                        ),
                      ),
                    ),
                  ],
                ),
                Form(
                  key: _formkey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: width * 0.14,
                            right: width * 0.15,
                            bottom: height * 0.10,
                            top: height * 0.10),
                        child: SizedBox(
                          height: height * 0.10,
                          child: const Image(
                            image: AssetImage('assets/logo.png'),
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.020),
                      nameField,
                      SizedBox(height: height * 0.02),
                      emailField,
                      SizedBox(height: height * 0.02),
                      passwordField,
                      SizedBox(height: height * 0.02),
                      confirmPasswordField,
                      SizedBox(height: height * 0.04),
                      signUpButton,
                      SizedBox(height: height * 0.002),
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

  // //
  // // // handling google sigin in
  // Future handleGoogleSignIn() async {
  //   final sp = context.read<SignInProvider>();
  //   final ip = context.read<InternetProvider>();
  //   await ip.checkInternetConnection();
  //
  //   if (ip.hasInternet == false) {
  //     openSnackbar(context, 'Check your Internet connection', Colors.red);
  //     googleController.reset();
  //   } else {
  //     await sp.signInWithGoogle().then((value) {
  //       if (sp.hasError == true) {
  //         openSnackbar(context, sp.errorCode.toString(), Colors.red);
  //         googleController.reset();
  //       } else {
  //         // checking whether user exists or not
  //         sp.checkUserExists().then((value) async {
  //           if (value == true) {
  //             // user exists
  //             await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
  //                 .saveDataToSharedPreferences()
  //                 .then((value) => sp.setSignIn().then((value) {
  //                       googleController.success();
  //
  //                       handleAfterSignIn();
  //                     })));
  //           } else {
  //             // user does not exist
  //             sp.saveDataToFirestore().then((value) => sp
  //                 .saveDataToSharedPreferences()
  //
  //                 .then((value) => sp.setSignIn().then((value) {
  //               // save user location
  //               saveUserLocation();
  //                       googleController.success();
  //                       handleAfterSignIn();
  //                     })));
  //           }
  //         });
  //       }
  //     });
  //   }
  // }

  void signUp(
      String email,
      String password,
      String displayName,
      ) async {
    if (_formkey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {postDetailsToFirestore()})
          .catchError((e) {
        showSnackBar(e!.toString(), Duration(seconds: 4));
      });
    }
  }

  // //handle After SignIn
  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      if(widget.screen == null ){
        nextScreenReplace(context, HomeScreen());
      }else if(widget.screen == 'WishlistScreen'){
        nextScreenReplace(context, HomeScreen());
      }else if(widget.screen == 'WishlistScreen'){
        nextScreenReplace(context, HomeScreen());
      }

    });
  }
  postDetailsToFirestore() async {
    // calling our fireStore
    //calling our user model
    // sending these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    final sp = context.read<SignInProvider>();

    UserModel userModel = UserModel();

    if (user != null) {
      //writing all the values
      userModel.displayName = nameEditingController.text;
      userModel.email = user.email;
      userModel.uid = user.uid;

      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .set(userModel.toMap())
          .then((value) => sp.setSignIn().then((value) {}));
      // saveUserLocation();

      // .then((value) => sp
      //     .saveDataToSharedPreferences()
      showSnackBar("AccountCreatedSuccessfully".tr, Duration(seconds: 4));

      handleAfterSignIn();
    }
  }

  // Future saveUserLocation() async {
  //   User? user = _auth.currentUser;
  //   final sp = context.read<SignInProvider>();
  //
  //   UserModel userModel = UserModel();
  //   FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  //   await firebaseFirestore.collection("locationUsers").doc(user?.uid).set({
  //     "name": nameEditingController.text,
  //     "email": user?.email,
  //     'longitude': long,
  //     'latitude': lat,
  //     "street": street,
  //     "city": city,
  //     "province": province,
  //   });
  // }
}