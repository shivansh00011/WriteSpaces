import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:writespace/screens%20and%20auth/loginscreen.dart';
import 'package:writespace/screens%20and%20auth/signupscreen.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  @override
  TextEditingController _emailController = new TextEditingController();
    Future<void> resetPassword() async {
    try {
      // Attempt to send the reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password Reset Email Has Been Sent"),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Check for specific error codes
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email not registered. Please check the email address."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An error occurred. Please try again."),
          ),
        );
      }
    }
  }
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
          padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reset Password",
                style: GoogleFonts.dmSerifText(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "Enter your email to send the reset password link",
                style: GoogleFonts.montserrat(),
              ),
              const SizedBox(height: 60),
              Text(
                "Email",
                style: GoogleFonts.montserrat(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'example@gmail.com',
                  hintStyle: GoogleFonts.montserrat(fontSize: 13),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.0), // transparent
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.black87),
                  ),
                ),
              ),
         
            
              const SizedBox(height: 32,),

              GestureDetector(
                onTap: resetPassword,
                child: Container(
                    height: 60,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 60, 60, 60),
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Center(
                      child: Text("Send email", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
                    ),
                
                ),
              ),
              const SizedBox(height: 12,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Loginscreen()));
                },
                child: Center(child: Text("Back to login", style: GoogleFonts.montserrat(fontSize: 13),),))

            ],
          ),
        ),
      ),
    );
  }
}
