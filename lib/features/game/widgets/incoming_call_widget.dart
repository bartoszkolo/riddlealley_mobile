import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class IncomingCallWidget extends StatelessWidget {
  final String callerName;
  final VoidCallback onAccept;

  const IncomingCallWidget({
    super.key,
    required this.callerName,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 2)),
            child: const Center(child: Icon(LucideIcons.user, size: 60, color: Colors.white)),
          ).animate(onPlay: (controller) => controller.repeat())
           .shimmer(duration: 2.seconds)
           .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.seconds),
          const SizedBox(height: 32),
          const Text("INCOMING ENCRYPTED CALL", style: TextStyle(color: Colors.greenAccent, fontSize: 12, letterSpacing: 4)),
          const SizedBox(height: 8),
          Text(callerName.toUpperCase(), style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallButton(LucideIcons.phoneOff, Colors.redAccent, "DECLINE", () {}),
                _buildCallButton(LucideIcons.phone, Colors.greenAccent, "ACCEPT", onAccept),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton(IconData icon, Color color, String label, VoidCallback onTap) {
    return Column(children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 70, height: 70,
          decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.5), width: 2)),
          child: Icon(icon, color: color, size: 30),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
         .shimmer(duration: 1.seconds),
      ),
      const SizedBox(height: 12),
      Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    ]);
  }
}