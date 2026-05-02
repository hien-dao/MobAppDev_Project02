import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to TropicaGuide!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tropical-themed image
            Image.asset(
              'assets/tropical_island.jpg',
              width: MediaQuery.of(context).size.width * 0.8,
            ),

            // Animated welcome message
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Ready to start your adventure?',
                    textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ),
            const SizedBox(height: 20),

            //Go to create account via /create_account  
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/createaccount');
              },
              child: const Text('Create Account'),
            ),
            SizedBox(height: 10),

            //Go to login via /login
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Login'),
            ),
          ],
        )
      ),
    );
  }
}