import 'package:flutter/material.dart';

/// Organic Shape Painter
/// Creates the decorative green and pink organic shapes in the background
class OrganicShapePainter extends CustomPainter {
  final Color color;
  final double topOffset;
  final double rightOffset;
  final bool isTopRight;

  OrganicShapePainter({
    required this.color,
    this.topOffset = 0,
    this.rightOffset = 0,
    this.isTopRight = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isTopRight) {
      // Top-right organic shape
      path.moveTo(size.width * 0.6 + rightOffset, topOffset);
      path.quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.1,
        size.width,
        size.height * 0.2,
      );
      path.lineTo(size.width, topOffset);
      path.close();
    } else {
      // Bottom-left organic shape
      path.moveTo(0, size.height * 0.7);
      path.quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.85,
        size.width * 0.35,
        size.height,
      );
      path.lineTo(0, size.height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Organic Background
/// Reusable widget for the decorative background shapes
class OrganicBackground extends StatelessWidget {
  final Widget child;

  const OrganicBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-right green shape
        Positioned(
          top: 0,
          right: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 400),
            painter: OrganicShapePainter(
              color: const Color(0xFFA8C5A5).withOpacity(0.6),
              isTopRight: true,
            ),
          ),
        ),
        // Top-right pink outline
        Positioned(
          top: 0,
          right: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 400),
            painter: OrganicShapePainter(
              color: const Color(0xFFE5C7C7).withOpacity(0.4),
              topOffset: -20,
              rightOffset: 30,
              isTopRight: true,
            ),
          ),
        ),
        // Bottom-left green shape
        Positioned(
          bottom: 0,
          left: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 400),
            painter: OrganicShapePainter(
              color: const Color(0xFFA8C5A5).withOpacity(0.6),
              isTopRight: false,
            ),
          ),
        ),
        // Bottom-left pink outline
        Positioned(
          bottom: 0,
          left: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 400),
            painter: OrganicShapePainter(
              color: const Color(0xFFE5C7C7).withOpacity(0.4),
              isTopRight: false,
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
