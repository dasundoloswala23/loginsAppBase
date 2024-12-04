import 'package:baseproject/provider/internet_provider.dart';
import 'package:baseproject/provider/sign_in_provider.dart';
import 'package:baseproject/provider/themes.dart';
import 'package:baseproject/screens/splashScreen/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'firebase_options.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: ((context) => SignInProvider()),
          ),
          ChangeNotifierProvider(
            create: ((context) => InternetProvider()),
          ),

        ],
        child: ChangeNotifierProvider(
            create: (context) => ThemeProvider(),
            builder: (context, _) {
              final themeProvider = Provider.of<ThemeProvider>(context);


              return MaterialApp(
                themeMode: themeProvider.themeMode,
                theme: Mytheme.lightTheme(context),
                darkTheme: Mytheme.darkTheme(context),
                debugShowCheckedModeBanner: false,
                home: SplashScreen(),
              );
            }
        ) );
  }
}
