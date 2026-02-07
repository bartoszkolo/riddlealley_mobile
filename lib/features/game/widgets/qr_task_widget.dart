import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

class QrTaskWidget extends StatefulWidget {
  final String expectedValue;
  final Function(String answer, int points) onComplete;

  const QrTaskWidget({
    super.key,
    required this.expectedValue,
    required this.onComplete,
  });

  @override
  State<QrTaskWidget> createState() => _QrTaskWidgetState();
}

class _QrTaskWidgetState extends State<QrTaskWidget> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                if (_isScanning)
                  MobileScanner(
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        final value = barcode.rawValue;
                        if (value != null && value.toUpperCase() == widget.expectedValue.toUpperCase()) {
                          setState(() => _isScanning = false);
                          widget.onComplete(value, 150);
                          break;
                        }
                      }
                    },
                  ),
                // Overlay
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24, width: 2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFF0040), width: 4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "SCAN THE TARGET CODE",
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
