import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GameHUD extends StatelessWidget {
  final int score;
  final String stageTitle;
  final double? distance;
  final VoidCallback onMenuClick;

  const GameHUD({
    super.key,
    required this.score,
    required this.stageTitle,
    this.distance,
    required this.onMenuClick,
  });

  @override
  Widget build(BuildContext context) {
    const neonRed = Color(0xFFFF0040);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.8),
        border: Border(bottom: const BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // XP Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: neonRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: neonRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.zap, color: neonRed, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$score XP',
                    style: GoogleFonts.jetbrainsMono(
                      color: neonRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Mission Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CURRENT MISSION',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    stageTitle.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            // Distance if available
            if (distance != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.navigation, color: Colors.blue, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${distance!.round()}M',
                      style: GoogleFonts.jetbrainsMono(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Menu Button
            IconButton(
              icon: const Icon(LucideIcons.menu, color: Colors.white),
              onPressed: onMenuClick,
            ),
          ],
        ),
      ),
    );
  }
}
