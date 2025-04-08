import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:writespace/screens%20and%20auth/loginscreen.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
   String? userName;
  String? email;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchEmail();
  }

  Future<void> fetchUserName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        setState(() {
          userName = userDoc.data()?['name'] ?? 'Guest';
        });
      } else {
        setState(() {
          userName = 'Guest';
        });
      }
    } catch (e) {
      print('Error fetching user name: $e');
      setState(() {
        userName = 'Guest';
      });
    }
  }

  Future<void> fetchEmail() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        setState(() {
          email = userDoc.data()?['email'] ?? 'Guest';
        });
      } else {
        setState(() {
          email = 'Guest';
        });
      }
    } catch (e) {
      print('Error fetching email: $e');
      setState(() {
        email = 'Guest';
      });
    }
  }
    Future<void> logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Loginscreen())); // Replace with your login page route
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error logging out. Please try again.',
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 240, 153, 182),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20,right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(child: Text("Profile", style: GoogleFonts.dmSerifText(fontSize: 23),),),
              ),
              const SizedBox(height: 25,),
              Text("Name", style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.bold),),
              const SizedBox(height: 15,),
              Container(
                height: 60,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 18, left: 14),
                  child: Text('$userName', style: TextStyle(fontSize: 16),),
                ),
              ),
               const SizedBox(height: 15,),
              Text("Email", style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.bold),),
              const SizedBox(height: 15,),
              Container(
                height: 60,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 18, left: 14),
                  child: Text('$email', style: TextStyle(fontSize: 16),),
                ),
              ),

              const SizedBox(height: 25,),
              GestureDetector(
                onTap:() => logOut(context),
                child: Container(
                  height: 60,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color.fromARGB(255, 230, 28, 95),
                      Colors.white
                    ]),
                    borderRadius: BorderRadius.circular(23),
                
                  ),
                  child: Center(child: Text('Logout', style: GoogleFonts.dmSerifText(fontSize: 19),),),
                ),
              )
          
          
            ],
          ),
        ),

      )
    );
  }
}