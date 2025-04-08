import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:intl/intl.dart';
import 'package:writespace/screens%20and%20auth/documentscreen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String name = "";
  String email = "";
  String firstLetter = "";
  String randomThought = "";

  final List<String> thoughts = [
    "You don’t have to be great to start, but you have to start to be great.",
    "Write what should not be forgotten.",
    "Your story matters. Share it.",
    "Every word is a step closer to your masterpiece.",
    "Start messy. Edit later. Just write.",
    "A blank page is full of possibilities.",
    "Create the things you wish existed.",
    "Your words can light someone’s darkness.",
  ];

  List<DocumentSnapshot> documents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getRandomThought();
    loadAllData();
  }

  Future<void> loadAllData() async {
    setState(() => isLoading = true);
    await fetchUserData();
    await fetchUserDocuments();
    setState(() => isLoading = false);
  }

  void getRandomThought() {
    final random = Random();
    randomThought = thoughts[random.nextInt(thoughts.length)];
  }

  Future<void> fetchUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '';
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> fetchUserDocuments() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final docs = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();

      setState(() {
        documents = docs.docs;
      });
    } catch (e) {
      print("Error fetching documents: $e");
    }
  }

  Future<void> deleteDocument(String docId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(docId)
          .delete();

      setState(() {
        documents.removeWhere((doc) => doc.id == docId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document deleted successfully')),
      );
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadAllData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 75, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.fromARGB(255, 240, 153, 182), Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 184, 182, 182),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                firstLetter,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$name's Workspace",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: GoogleFonts.montserrat(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Thought of the Day
                      Container(
                        height: 190,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset('assets/back.jpg', fit: BoxFit.cover),
                              Container(color: Colors.black.withOpacity(0.5)),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    '"$randomThought"',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.ptSerif(
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Notes section
                      Text(
                        "Your work",
                        style: GoogleFonts.dmSerifText(fontSize: 18),
                      ),
                      const SizedBox(height: 10,),

                      if (documents.isEmpty)
                     
                        Text(
                          "No documents created yet.",
                          style: GoogleFonts.montserrat(fontSize: 14),
                        )
                          
                      else
                    
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final doc = documents[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final title = data['title'] ?? 'Untitled';
                            final body = data['body'] ?? '';
                            final timestamp = data['timestamp'] as Timestamp?;

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NewNotePage(docId: doc.id),
                                  ),
                                ).then((_) => loadAllData());
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                 
                                  children: [
                                    Image.asset('assets/notes.png', height: 70,),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                             Text(
                    body.length > 100 ? '${body.substring(0, 100)}...' : body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(fontSize: 13),
                  ),
                                          const SizedBox(height: 6),
                                          if (timestamp != null)
                                             Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "Created: ${formatTimestamp(timestamp)}",
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () async {
                                        await deleteDocument(doc.id);
                                      },
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 8),

                      // Add new document
                      DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        color: Colors.grey,
                        strokeWidth: 1.5,
                        dashPattern: const [8, 4],
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NewNotePage(),
                              ),
                            ).then((_) => loadAllData());
                          },
                          child: Container(
                            width: double.infinity,
                            height: 95,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, size: 30, color: Colors.black54),
                                const SizedBox(height: 8),
                                Text(
                                  "Create a new document",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
