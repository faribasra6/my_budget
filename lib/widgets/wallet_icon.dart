import 'package:flutter/material.dart';

class WalletIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WalletIcon({
    super.key,
    this.size = 80,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: WalletPainter(color: color),
    );
  }
}

class WalletPainter extends CustomPainter {
  final Color color;

  WalletPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final walletWidth = size.width * 0.7;
    final walletHeight = size.height * 0.6;

    // Main wallet body
    final walletRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: walletWidth,
        height: walletHeight,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(walletRect, paint);

    // Wallet fold at top
    final foldPath = Path();
    final foldTop = center.dy - walletHeight / 2;
    final foldBottom = center.dy - walletHeight / 4;
    final foldLeft = center.dx - walletWidth / 2;
    final foldRight = center.dx + walletWidth / 4;

    foldPath.moveTo(foldLeft, foldTop);
    foldPath.lineTo(foldRight - 8, foldTop);
    foldPath.quadraticBezierTo(foldRight, foldTop, foldRight, foldTop + 8);
    foldPath.lineTo(foldRight, foldBottom);
    foldPath.lineTo(foldLeft, foldBottom);
    foldPath.quadraticBezierTo(foldLeft - 8, foldBottom, foldLeft - 8, foldBottom - 8);
    foldPath.lineTo(foldLeft - 8, foldTop + 8);
    foldPath.quadraticBezierTo(foldLeft - 8, foldTop, foldLeft, foldTop);
    foldPath.close();

    final foldPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawPath(foldPath, foldPaint);

    // Card slot
    final cardSlotRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - walletHeight / 6),
        width: walletWidth * 0.7,
        height: 3,
      ),
      const Radius.circular(1.5),
    );
    final cardSlotPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(cardSlotRect, cardSlotPaint);

    // Small card peeking out
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx - walletWidth / 6, center.dy - walletHeight / 3),
        width: walletWidth * 0.4,
        height: 8,
      ),
      const Radius.circular(2),
    );
    final cardPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(cardRect, cardPaint);

    // Wallet button
    final buttonCenter = Offset(center.dx + walletWidth / 3, center.dy);
    canvas.drawCircle(buttonCenter, 6, strokePaint);
    canvas.drawCircle(buttonCenter, 3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}