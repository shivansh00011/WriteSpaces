import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

String cleanMarkdown(String input) {
  return input.replaceAll(RegExp(r'\*+'), '');

}

String newcleanMarkdown(String input) {
  return input.replaceAll(RegExp(r'\*\*(.*?)\*\*'), '');
}

Map<String, String> extractSummaryAndExplanation(String text) {
  final cleaned = cleanMarkdown(text);
  final parts = cleaned.split(RegExp(r"Explanation in Layman\'s Terms:|Explanation:"));

  String summary = parts[0].replaceFirst(RegExp(r'Summary:'), '').trim();
  String explanation = parts.length > 1 ? parts[1].trim() : '';

  return {
    'summary': summary,
    'explanation': explanation,
  };
}

class NewNotePage extends StatefulWidget {
  final String? docId;
  const NewNotePage({Key? key, this.docId}) : super(key: key);

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _isGenerating = false;
  String _aiResponse = '';
  bool _showResponseBox = false;

  @override
  void initState() {
    super.initState();
    if (widget.docId != null) {
      fetchExistingNote();
    }
  }

  Future<void> fetchExistingNote() async {
    final user = _auth.currentUser;
    if (user == null) return;
    setState(() => _isLoading = true);

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(widget.docId)
        .get();

    if (doc.exists) {
      _titleController.text = doc['title'] ?? '';
      _bodyController.text = doc['body'] ?? '';
    }

    setState(() => _isLoading = false);
  }

  Future<void> saveNote() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final notesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes');

    final noteData = {
      'title': _titleController.text.trim(),
      'body': _bodyController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'uid': user.uid,
    };

    if (widget.docId != null) {
      await notesRef.doc(widget.docId).update(noteData);
    } else {
      await notesRef.add(noteData);
    }
  }

  Future<void> _generateSummary() async {
    setState(() {
      _isGenerating = true;
      _showResponseBox = true;
      _aiResponse = '';
    });

    final promptText = "Summarize and explain this in layman terms:\n\n${_bodyController.text.trim()}";

    try {
      final response = await http.post(
        Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=YOUR_API_KEY"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": promptText}
              ]
            }
          ]
        }),
      );

      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      setState(() {
        _aiResponse = text ?? 'Could not generate summary.';
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _aiResponse = 'Error: $e';
        _isGenerating = false;
      });
    }
  }

  Future<void> _generateNoteFromPrompt(String prompt) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isGenerating = true;
      _titleController.clear();
      _bodyController.clear();
    });

    final promptText = 'Generate a note with a concise and highly relevant title and a detailed body based on the prompt: "$prompt". Respond in the format — Title: <title> Body: <body>.';


    try {
      final response = await http.post(
        Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=YOUR_API_KEY"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": promptText}
              ]
            }
          ]
        }),
      );

      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

      final titleMatch = RegExp(r'Title:\s*(.*)').firstMatch(text);
      final bodyMatch = RegExp(r'Body:\s*(.*)', dotAll: true).firstMatch(text);

      final extractedTitle = titleMatch?.group(1)?.trim() ?? '';
      final extractedBody = bodyMatch?.group(1)?.trim() ?? '';

     
      final cleanedBody = newcleanMarkdown(extractedBody);
      for (int i = 0; i <= extractedTitle.length; i++) {
        await Future.delayed(const Duration(milliseconds: 40));
        _titleController.text = cleanedBody.substring(0, i);
        _titleController.selection = TextSelection.collapsed(offset: _titleController.text.length);
      }

      // Type out body
      for (int i = 0; i <= extractedBody.length; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
        _bodyController.text = extractedBody.substring(0, i);
        _bodyController.selection = TextSelection.collapsed(offset: _bodyController.text.length);
      }
        await saveNote();
      

    } catch (e) {
      print("Error generating note: $e");
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _showNoteDialog() {
    final TextEditingController _promptController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Note Assistant",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurpleAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _promptController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: "Ask me to write the notes for you",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _generateNoteFromPrompt(_promptController.text.trim());
                    },
                    child: const Text("Generate", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHexagonButton({required VoidCallback onTap, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        clipper: HexagonClipper(),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.deepPurpleAccent,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAIResponseBox() {
    if (!_showResponseBox) return const SizedBox.shrink();

    final responseData = extractSummaryAndExplanation(_aiResponse);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: _isGenerating
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (responseData['summary']!.isNotEmpty) ...[
                  const Text('Summary:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(responseData['summary']!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                ],
                if (responseData['explanation']!.isNotEmpty) ...[
                  const Text('Explanation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(responseData['explanation']!, style: const TextStyle(fontSize: 14)),
                ]
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(widget.docId != null ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await saveNote();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 240, 153, 182), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 140, 16, 16),
              child: SizedBox.expand(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _titleController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Title',
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _bodyController,
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: 'Start writing your note...',
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: 10),
                          _buildAIResponseBox(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 7,
                      bottom: 88,
                      child: _buildHexagonButton(
                        onTap: _showNoteDialog,
                        icon: Icons.auto_stories_outlined,
                      ),
                    ),
                    Positioned(
                      right: 7,
                      bottom: 16,
                      child: _buildHexagonButton(
                        onTap: _generateSummary,
                        icon: Icons.smart_toy_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.25, 0);
    path.lineTo(w * 0.75, 0);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.75, h);
    path.lineTo(w * 0.25, h);
    path.lineTo(0, h * 0.5);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
