import 'package:flutter/material.dart';
import 'fnb_brand_header.dart';

class AdviceSpeechBubble extends StatelessWidget {
  const AdviceSpeechBubble({
    super.key,
    required this.adviceText,
    this.tag = 'Personalised AI Financial Advice',
  });

  final String adviceText;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: fnbPaleTeal,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xff8ce1e5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: fnbTeal.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: fnbTeal, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    tag.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: fnbTeal,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '“$adviceText”',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: fnbDark,
                ),
              ),
            ],
          ),
        ),
        // Speech bubble indicator triangle
        Center(
          child: CustomPaint(
            size: const Size(16, 8),
            painter: _TrianglePainter(color: fnbPaleTeal, borderColor: const Color(0xff8ce1e5)),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.color, required this.borderColor});
  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
