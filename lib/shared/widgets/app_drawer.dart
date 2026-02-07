import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const neonRed = Color(0xFFFF0040);
    const bgDark = Color(0xFF0F172A);

    return Drawer(
      backgroundColor: bgDark,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                   RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      children: const [
                        TextSpan(text: 'RIDDLE'),
                        TextSpan(
                          text: 'ALLEY',
                          style: TextStyle(color: neonRed),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildMenuItem(context, 'MAP', Icons.map, onTap: () {
                    // TODO: Navigate to Map
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(context, 'HOW IT WORKS', Icons.info_outline),
                  _buildMenuItem(context, 'FAQ', Icons.help_outline),
                  _buildMenuItem(context, 'BLOG', Icons.article_outlined),
                  const Divider(color: Colors.white10, height: 32),
                  _buildMenuItem(context, 'PROFILE', Icons.person_outline),
                ],
              ),
            ),

            // Language Switcher Placeholder
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLangOption('EN', true, neonRed),
                  const SizedBox(width: 16),
                  _buildLangOption('PL', false, neonRed),
                ],
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'v0.1.0 • RIDDLEALLEY MOBILE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white24,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      hoverColor: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildLangOption(String code, bool isSelected, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? accent.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color: isSelected ? accent : Colors.white24,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code,
        style: GoogleFonts.inter(
          color: isSelected ? accent : Colors.white54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
