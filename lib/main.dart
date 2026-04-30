import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'SCREENS/firstscreen.dart';
import 'SCREENS/loginscreen.dart';
import 'SCREENS/mainscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Making sure Firebase has loaded
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proj2',
      initialRoute: '/',
      //A way to plot the different pages
      routes: {
    '/': (context) => StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
        //Bypass for logging in each time
            if (snapshot.hasData) {
              return const mainscreen();
            }
        //Welcome screen
            return const firstscreen();
          },
        ),
    //Identifying the other pages
    '/login': (context) => const loginscreen(),
    '/main': (context) => const mainscreen(),
  },
  );
  }
}