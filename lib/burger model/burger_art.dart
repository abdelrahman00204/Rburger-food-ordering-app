import 'package:flutter/material.dart';
import 'package:rburger/burger%20model/burger_selection.dart';

class BurgerPreview extends StatelessWidget {
  final BurgerSelection selection;

  const BurgerPreview({super.key, required this.selection});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: CustomPaint(painter: _BurgerPainter(selection)),
    );
  }
}

class _BurgerPainter extends CustomPainter {
  final BurgerSelection selection;
  _BurgerPainter(this.selection);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bunWidth = size.width * 0.62;
    double y = size.height * 0.08;

    final topBunColors = selection.hasBriocheBun
        ? const [Color(0xFFF2AE55), Color(0xFFCC7A2C)]
        : const [Color(0xFFEBA24C), Color(0xFFC0721F)];

    y = _drawTopBun(
      canvas,
      centerX,
      y,
      bunWidth,
      60,
      topBunColors,
      sesame: true,
    );
    y = _drawSauceLine(canvas, centerX, y, bunWidth - 10);

    // Lettuce peeking out
    y = _drawPillLayer(
      canvas,
      centerX,
      y,
      bunWidth + 14,
      14,
      const Color(0xFF6FB84F),
    );

    // Cheese now matches patty width and shape — no more overhanging corners
    if (selection.hasCheese) {
      y = _drawPillLayer(
        canvas,
        centerX,
        y - 2,
        bunWidth - 6,
        10,
        const Color(0xFFF2C230),
      );
    }

    // Patty stack — one fused slab even when double
    final pattyCount = selection.isDoublePatty ? 2 : 1;
    y = _drawPattyStack(canvas, centerX, y, bunWidth - 6, pattyCount);

    _drawToppingFlecks(canvas, centerX, y - 8, bunWidth - 20);

    y = _drawSauceLine(canvas, centerX, y, bunWidth - 10);
    _drawBottomBun(canvas, centerX, y, bunWidth + 14, 30);
  }

  double _drawTopBun(
    Canvas canvas,
    double centerX,
    double top,
    double width,
    double height,
    List<Color> gradientColors, {
    bool sesame = false,
  }) {
    final rect = Rect.fromCenter(
      center: Offset(centerX, top + height / 2),
      width: width,
      height: height,
    );
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(height),
      topRight: Radius.circular(height),
      bottomLeft: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    );
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors,
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);

    if (sesame) {
      final seedPaint = Paint()..color = const Color(0xFFFCEBC7);
      const positions = [-0.28, -0.1, 0.08, 0.26, -0.18, 0.17];
      for (final dx in positions) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(centerX + dx * width, top + height * 0.4),
            width: 5,
            height: 3,
          ),
          seedPaint,
        );
      }
    }
    return top + height;
  }

  double _drawSauceLine(
    Canvas canvas,
    double centerX,
    double top,
    double width,
  ) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, top + 2),
        width: width,
        height: 4,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFA6392B));
    return top + 4;
  }

  double _drawPillLayer(
    Canvas canvas,
    double centerX,
    double top,
    double width,
    double height,
    Color color,
  ) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, top + height / 2),
        width: width,
        height: height,
      ),
      Radius.circular(height / 2),
    );
    canvas.drawRRect(rrect, Paint()..color = color);
    return top + height - 4;
  }

  double _drawPattyStack(
    Canvas canvas,
    double centerX,
    double top,
    double width,
    int count,
  ) {
    const singleHeight = 24.0;
    const overlap = 6.0;
    final totalHeight = singleHeight * count - overlap * (count - 1);

    final rect = Rect.fromCenter(
      center: Offset(centerX, top + totalHeight / 2),
      width: width,
      height: totalHeight,
    );
    final radius = totalHeight / 2 < 16 ? totalHeight / 2 : 16.0;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF8B5E3C), Color(0xFF5C3820)],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);

    if (count > 1) {
      final linePaint = Paint()
        ..color = const Color(0xFF4A2814).withValues(alpha: 0.6)
        ..strokeWidth = 1.2;
      for (var i = 1; i < count; i++) {
        final lineY = top + (singleHeight - overlap) * i;
        canvas.drawLine(
          Offset(centerX - width / 2 + 10, lineY),
          Offset(centerX + width / 2 - 10, lineY),
          linePaint,
        );
      }
    }
    return top + totalHeight - 4;
  }

  void _drawToppingFlecks(
    Canvas canvas,
    double centerX,
    double y,
    double width,
  ) {
    if (selection.hasOnion) {
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
      for (final dx in [-0.3, -0.05, 0.2]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(centerX + dx * width, y),
            width: 10,
            height: 4,
          ),
          paint,
        );
      }
    }
    if (selection.hasMushroom) {
      final paint = Paint()..color = const Color(0xFF8B6F52);
      for (final dx in [-0.18, 0.1, 0.32]) {
        canvas.drawCircle(Offset(centerX + dx * width, y + 2), 4, paint);
      }
    }
    if (selection.hasPickles) {
      final paint = Paint()..color = const Color(0xFF7FA850);
      for (final dx in [-0.25, 0.0, 0.25]) {
        canvas.drawCircle(Offset(centerX + dx * width, y - 3), 3, paint);
      }
    }
  }

  void _drawBottomBun(
    Canvas canvas,
    double centerX,
    double top,
    double width,
    double height,
  ) {
    final rect = Rect.fromCenter(
      center: Offset(centerX, top + height / 2),
      width: width,
      height: height,
    );
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
      bottomLeft: Radius.circular(height),
      bottomRight: Radius.circular(height),
    );
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEBA24C), Color(0xFFC0721F)],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _BurgerPainter oldDelegate) {
    final s = selection;
    final o = oldDelegate.selection;
    return s.bun.id != o.bun.id ||
        s.patty.id != o.patty.id ||
        s.cheese.id != o.cheese.id ||
        s.toppings.length != o.toppings.length ||
        s.hasOnion != o.hasOnion ||
        s.hasMushroom != o.hasMushroom ||
        s.hasPickles != o.hasPickles;
  }
}
