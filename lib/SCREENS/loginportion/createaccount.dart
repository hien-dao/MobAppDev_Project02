import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../mainscreen.dart';

class createaccount extends StatefulWidget{
  const createaccount({super.key});

  @override
  State<createaccount> createState() => _createaccountState();
}

class _createaccountState extends State<createaccount>{
  final emailController= TextEditingController();
  final usernameController= TextEditingController();
  final passwordController= TextEditingController();
  bool loading=false;

  Future<void> createAccount() async{
    setState((){
      loading = true;

    });

    try{
      String email = emailController.text.trim();
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();

      UserCredential userCredential = 
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
          'email': email,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
        });
      
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder:(context) => const mainscreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Create Account Failed: $e")),
        );
    }

    setState((){
      loading = false;
    });
  }
  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: createAccount,
                    child: const Text("Create Account"),
                  ),
          ],
        ),
      ),
    );
  }
}
