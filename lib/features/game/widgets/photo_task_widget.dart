import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotoTaskWidget extends StatefulWidget {
  final String targetDescription;
  final Function(String answer, int points) onComplete;

  const PhotoTaskWidget({
    super.key,
    required this.targetDescription,
    required this.onComplete,
  });

  @override
  State<PhotoTaskWidget> createState() => _PhotoTaskWidgetState();
}

class _PhotoTaskWidgetState extends State<PhotoTaskWidget> {
  File? _image;
  bool _isAnalyzing = false;
  String? _error;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 70,
    );

    if (photo != null) {
      setState(() {
        _image = File(photo.path);
        _error = null;
      });
      _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Initialize Gemini Vision
      // TODO: Replace with secure key
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'GEMINI_API_KEY',
      );

      final bytes = await _image!.readAsBytes();
      final content = [
        Content.multi([
          DataPart('image/jpeg', bytes),
          TextPart('Analyze this photo. Does it contain the following object: "${widget.targetDescription}"? Respond with "MATCH_FOUND" if it does, followed by a short one-sentence confirmation. If not, explain why.'),
        ])
      ];

      final response = await model.generateContent(content);
      final text = response.text ?? "";

      if (text.contains("MATCH_FOUND")) {
        widget.onComplete("PHOTO_VERIFIED", 300);
      } else {
        setState(() {
          _error = text;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Transmission failed: $e";
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const neonRed = Color(0xFFFF0040);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Preview Box
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _image != null
                ? Stack(
                    children: [
                      Image.file(_image!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                      if (_isAnalyzing)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(color: neonRed),
                                const SizedBox(height: 16),
                                Text("ANALYZING EVIDENCE...", style: GoogleFonts.jetbrainsMono(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.image, size: 64, color: Colors.white24),
                      const SizedBox(height: 12),
                      Text("NO EVIDENCE CAPTURED", style: GoogleFonts.inter(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: neonRed, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        
        Text(
          "MISSION TARGET: ${widget.targetDescription.toUpperCase()}",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _takePhoto,
            icon: const Icon(LucideIcons.camera),
            label: Text(_image == null ? "LAUNCH CAMERA" : "TAKE NEW PHOTO", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
            style: ElevatedButton.styleFrom(
              backgroundColor: neonRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ],
    );
  }
}
