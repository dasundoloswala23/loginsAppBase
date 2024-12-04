
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/sign_in_provider.dart';
import '../../provider/themes.dart';
import '../userScreens/loginScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Center(
child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text('displayname ${sp.displayName}'),
    Text('uid ${sp.uid}'),
    Text('email ${sp.email}'),
    Text('themeProvider ${themeProvider}'),
    Text('sp.isSignedIn ${    sp.isSignedIn}'),

SizedBox(height: 20,),
    ElevatedButton(onPressed: (){
      sp.userSignOut;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>  LoginScreen()));
    }, child: Text('SignOut')),
  ],
),
      ),
    );
  }
}
