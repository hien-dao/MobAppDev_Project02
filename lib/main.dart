import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proj2',
      home: const FirebaseReadyScreen(),
    );
  }
}

class FirebaseReadyScreen extends StatelessWidget {
  const FirebaseReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connected'),
      ),
      body: const Center(
        child: Text(
          'Firebase setup is complete.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}