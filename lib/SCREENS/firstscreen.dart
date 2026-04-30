import 'package:flutter/material.dart';

class firstscreen extends StatelessWidget {
  const firstscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         const Text(
          'Welcome',
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
        //Go to login via /login
        ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Login'),
            ),
        //Go to create account via /create_account  
        ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create_account');
              },
              child: const Text('Create Account'),
            ),
        ],
        ),
      ),
    );
  }
}