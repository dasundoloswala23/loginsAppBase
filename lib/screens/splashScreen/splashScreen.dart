import 'package:baseproject/screens/homeScreen/homeScreen.dart';
import 'package:baseproject/screens/userScreens/loginScreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/provider.dart';

import '../../provider/sign_in_provider.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    init();

  }

  Future<void> init() async {
    final sp = context.read<SignInProvider>();
    if (sp.isSignedIn) {
      Timer(Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen(),));
      });
    }else{
      Timer(Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen(),));
      });
    }
  }
  late double width, height;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height:height*0.3),
            SizedBox(height:100,width:100,child: Image.asset('assets/logo.png')),
            Text("name")
          ],
        ),
      ),
    );
  }

}
