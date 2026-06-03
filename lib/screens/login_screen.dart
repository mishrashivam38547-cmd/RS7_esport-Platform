import 'package:flutter/material.dart';
import 'package:firebase_auth/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginWithEmail() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      // Configuration targeted specifically for web/android framework deployment
      GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: "160557620454-3j87g6fmouio1q7mqsvb20drauq4qh14.apps.googleusercontent.com"
      ).signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await _auth.signInWithCredential(credential);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Sign-In failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Placeholder using specs from image_3.png
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/image_3.png'), fit: BoxFit.contain)
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: RS7Theme.primaryRed, minimumSize: const Size(double.infinity, 50)),
                onPressed: loginWithEmail,
                child: const Text("Login / Register", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                icon: const Icon(Icons.login, color: Colors.blue),
                label: const Text("Sign In with Google"),
                onPressed: loginWithGoogle,
              )
            ],
          ),
        ),
      ),
    );
  }
}
