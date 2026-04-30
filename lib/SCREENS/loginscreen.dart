import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mainscreen.dart';

class loginscreen extends StatefulWidget {
  const loginscreen({super.key});
  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen>{
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //Tracking if the  my app is logging in
  bool loading = false;
  //Function login user, waits for firebase, loads screen for met conditions
  Future<void> loginUser() async {
    setState((){
      loading= true;
    });
    try{
      //Initialization of the login variables
      String username= usernameController.text.trim();
      String password = passwordController.text.trim();
      String email = "$username@proj2.com"; //Put restrictions around email inserts

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
          'username': username,
          'last login': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));

        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const mainscreen()),
        );
        } catch(e){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login Failed: $e")),
            );
        }
      setState((){
        loading = false;
      });
    }
    @override
    void dispose(){
      usernameController.dispose();
      passwordController.dispose();
      super.dispose();
    }

    
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller:usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height:15),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height:15),
            loading
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: loginUser, child: const Text("Login")),

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