import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:writespace/screens%20and%20auth/loginscreen.dart';
class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  @override
   bool obscurePassword = true;
   TextEditingController _nameController = new TextEditingController();
   TextEditingController _emailController = new TextEditingController();
   TextEditingController _passwordController = new TextEditingController();

     final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<void> _signUp() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'uid': userCredential.user?.uid,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Loginscreen()),
      );
    } on FirebaseAuthException catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Signup failed"),
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
          padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create an account",
                style: GoogleFonts.dmSerifText(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "Enter your name, email and password to signup",
                style: GoogleFonts.montserrat(),
              ),
              const SizedBox(height: 60),
              Text(
                "Name",
                style: GoogleFonts.montserrat(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Elisa',
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
              const SizedBox(height: 26,),
             
            

              GestureDetector(
                onTap: _signUp,
                child: Container(
                    height: 60,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 60, 60, 60),
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Center(
                      child: Text("Signup", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
                    ),
                
                ),
              ),
              const SizedBox(height: 12,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Loginscreen()));
                },
                child: Center(child: Text("Already have an account?", style: GoogleFonts.montserrat(fontSize: 13),),))

            ],
          ),
        ),
      ),
    );}
}