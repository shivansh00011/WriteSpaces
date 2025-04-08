import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:writespace/screens%20and%20auth/forgotpassword.dart';
import 'package:writespace/screens%20and%20auth/homescreen.dart';
import 'package:writespace/screens%20and%20auth/navbar.dart';
import 'package:writespace/screens%20and%20auth/signupscreen.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  String email = "",password ="";
  bool obscurePassword = true;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  bool isLoading = false;
    Future<void> loginUser() async {
    setState(() {
      isLoading = true; // Start loading spinner
    });

    try {
      // Firebase authentication for signing in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Navigate to HomePage on successful login
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const NavBar()));

    } catch (e) {
      // Display an error message if sign in fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid credentials. Please try again."),
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading spinner
      });
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
          padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Login to account",
                style: GoogleFonts.dmSerifText(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "Enter your email and password to login",
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
              const SizedBox(height: 20),
              Text(
                "Password",
                style: GoogleFonts.montserrat(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: '***********',
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                     
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14,),
              Padding(
                padding: const EdgeInsets.only(left: 220),
                child: GestureDetector(
                  onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Forgotpassword()));
                },
                  child: Text("Forgot Password?", style: GoogleFonts.montserrat(color: const Color.fromARGB(255, 14, 135, 235), fontWeight: FontWeight.w700),)),
              ),
              const SizedBox(height: 32,),

              GestureDetector(
                onTap: loginUser,
                child: Container(
                    height: 60,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 60, 60, 60),
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Center(
                      child: Text("Login", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
                    ),
                
                ),
              ),
              const SizedBox(height: 12,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Signupscreen()));
                },
                child: Center(child: Text("Don't have an account?", style: GoogleFonts.montserrat(fontSize: 13),),))

            ],
          ),
        ),
      ),
    );
  }
}
