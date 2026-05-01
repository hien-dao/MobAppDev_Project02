import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../mainscreen.dart';

class loginscreen extends StatefulWidget {
  const loginscreen({super.key});
  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen>{
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //Tracking if the  my app is logging in
  bool loading = false;
  //Function login user, waits for firebase, loads screen for met conditions
  Future<void> loginUser() async {
    setState((){
      loading= true;
    });
    try{
      //reads the email entered by the user
      String email= emailController.text.trim();
      String password = passwordController.text.trim();
      //firebase authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      //starts main screen after succesful login.
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
      emailController.dispose();
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
              controller:emailController,
              decoration: const InputDecoration(
                labelText: "Email",
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
            //goes to create account page
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/createaccount');
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}