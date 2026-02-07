import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/models/task_model.dart';

class AbcdTaskWidget extends StatelessWidget {
  final List<LocalizedText> options;
  final Function(String answer, int points) onComplete;
  final String lang;

  const AbcdTaskWidget({
    super.key,
    required this.options,
    required this.onComplete,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final text = getLocalizedText(entry.value, lang);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
              onPressed: () => onComplete(text, 100),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0040).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: const TextStyle(color: const Color(0xFFFF0040), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      text,
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
