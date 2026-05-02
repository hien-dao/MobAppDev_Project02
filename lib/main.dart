import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'SCREENS/firstscreen.dart';
import 'SCREENS/loginportion/loginscreen.dart';
import 'SCREENS/mainscreen.dart';
import 'SCREENS/loginportion/createaccount.dart';

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
              return const MainScreen();
            }
        //Welcome screen
            return const FirstScreen();
          },
        ),
    //Identifying the other pages
    '/login': (context) => const LoginScreen(),
    '/main': (context) => const MainScreen(),
    '/createaccount': (context) => const CreateAccountScreen(),
  },
  );
  }
}