import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:writespace/screens%20and%20auth/homescreen.dart';

import 'package:writespace/screens%20and%20auth/loginscreen.dart';
import 'package:writespace/screens%20and%20auth/navbar.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          // Handle connection states
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // If the user is logged in, show the home page
              return const NavBar(); 
            } else if (snapshot.hasError) {
              // Handle errors
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for authentication check
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // If no user is logged in, show the intro page
          return const Loginscreen();
        },
      ),
    );
  }
}