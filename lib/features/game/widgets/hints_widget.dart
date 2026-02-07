import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/models/task_model.dart';
import '../providers/game_provider.dart';

class HintsWidget extends ConsumerWidget {
  final List<Hint> hints;
  final List<int> revealedIndices;
  final String lang;

  const HintsWidget({
    super.key,
    required this.hints,
    required this.revealedIndices,
    required this.lang,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const neonRed = Color(0xFFFF0040);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.helpCircle, color: Colors.white54, size: 16),
            const SizedBox(width: 8),
            Text(
              "AVAILABLE HINTS",
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...hints.asMap().entries.map((entry) {
          final index = entry.key;
          final hint = entry.value;
          final isRevealed = revealedIndices.contains(index);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isRevealed ? Colors.blue.withOpacity(0.3) : Colors.white10,
                ),
              ),
              child: isRevealed
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.unlock, color: Colors.blue, size: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              getLocalizedText(hint.text, lang),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListTile(
                      onTap: () => _showRevealDialog(context, ref, index, hint.cost),
                      leading: const Icon(LucideIcons.lock, color: Colors.white24, size: 16),
                      title: Text(
                        "UNLOCK HINT #${index + 1}",
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: neonRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "-${hint.cost} XP",
                          style: const TextStyle(color: neonRed, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showRevealDialog(BuildContext context, WidgetRef ref, int index, int cost) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("UNLOCK HINT?", style: TextStyle(color: Colors.white)),
        content: Text("This will cost you $cost XP. Proceed?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(gameStateProvider.notifier).revealHint(index, cost);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0040)),
            child: const Text("UNLOCK"),
          ),
        ],
      ),
    );
  }
}
