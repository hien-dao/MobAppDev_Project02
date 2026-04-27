import 'package:flutter/material.dart';

class mainscreen extends StatelessWidget {
  const mainscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: const Center(
        child: Text(
          'Main screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}