import 'package:flutter/material.dart';
import 'dart:math';

class FindBestRoutesOnboarding extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const FindBestRoutesOnboarding({
    Key? key,
    this.currentPage = 1,
    this.totalPages = 3,
    this.onNext,
    this.onSkip,
  }) : super(key: key);

  @override
  State<FindBestRoutesOnboarding> createState() =>
      _FindBestRoutesOnboardingState();
}

class _FindBestRoutesOnboardingState extends State<FindBestRoutesOnboarding>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _pinPulseController;

  @override
  void initState() {
    super.initState();

    _rotateController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _pinPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pinPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Icon Section
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _rotateController,
                    _pinPulseController,
                  ]),
                  builder: (context, child) {
                    return CustomPaint(
                      painter: BestRoutesIconPainter(
                        rotationValue: _rotateController.value,
                        pulseValue: _pinPulseController.value,
                      ),
                      size: const Size(280, 280),
                    );
                  },
                ),
              ),
            ),
            // Text Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Text(
                    'Find best routes',
                    textAlign: TextAlign.center,
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF424242),
                          letterSpacing: 0.5,
                        ) ??
                        const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF424242),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Discover optimal routes with intelligent pathfinding',
                    textAlign: TextAlign.center,
                    style:
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF999999),
                          height: 1.5,
                        ) ??
                        const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Page Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.totalPages,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: PageIndicator(isActive: index == widget.currentPage),
                  ),
                ),
              ),
            ),
            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login_screen'),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/ride_onboarding'),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final bool isActive;

  const PageIndicator({Key? key, required this.isActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 10 : 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFBDBDBD),
      ),
    );
  }
}

class BestRoutesIconPainter extends CustomPainter {
  final double rotationValue;
  final double pulseValue;

  BestRoutesIconPainter({
    required this.rotationValue,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const circleRadius = 90.0;

    // Draw rotating dashed path
    _drawDashedCirclePath(canvas, center, circleRadius);

    // Draw animated location pins
    _drawLocationPins(canvas, center, circleRadius);

    // Draw central tower
    _drawCentralTower(canvas, center);

    // Draw checkmark at bottom
    _drawCheckmarkIcon(canvas, center);
  }

  void _drawDashedCirclePath(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = const Color(0xFF81C784)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashLength = 10.0;
    const gapLength = 6.0;
    const segmentLength = dashLength + gapLength;

    final circumference = 2 * pi * radius;
    final dashCount = (circumference / segmentLength).ceil();

    for (int i = 0; i < dashCount; i++) {
      final startAngle =
          ((i * segmentLength) / radius) + (rotationValue * 2 * pi);
      final endAngle = startAngle + (dashLength / radius);

      final startPoint = Offset(
        center.dx + radius * cos(startAngle),
        center.dy + radius * sin(startAngle),
      );
      final endPoint = Offset(
        center.dx + radius * cos(endAngle),
        center.dy + radius * sin(endAngle),
      );

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  void _drawLocationPins(Canvas canvas, Offset center, double radius) {
    const pinCount = 3;
    const outerRadius = 11.0;
    const innerRadius = 6.0;

    final pinFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pinStrokePaint = Paint()
      ..color = const Color(0xFF81C784)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < pinCount; i++) {
      final angle =
          ((i * 360) / pinCount) * pi / 180 + (rotationValue * 2 * pi);
      final pinPos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      // Pulse effect on pin size
      final pulseScale = 0.9 + (pulseValue * 0.15);

      // Outer circle
      canvas.drawCircle(pinPos, outerRadius * pulseScale, pinStrokePaint);

      // Inner circle
      canvas.drawCircle(pinPos, innerRadius, pinFillPaint);
      canvas.drawCircle(pinPos, innerRadius, pinStrokePaint);

      // Pin pointer/tail
      final tailLength = 12.0;
      final tailStartRadius = 7.0;

      final tailStartPos = Offset(
        pinPos.dx + tailStartRadius * cos(angle),
        pinPos.dy + tailStartRadius * sin(angle),
      );

      final tailEndPos = Offset(
        pinPos.dx + tailLength * cos(angle),
        pinPos.dy + tailLength * sin(angle),
      );

      final tailPaint = Paint()
        ..color = const Color(0xFF81C784)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(tailStartPos, tailEndPos, tailPaint);
    }
  }

  void _drawCentralTower(Canvas canvas, Offset center) {
    final strokePaint = Paint()
      ..color = const Color(0xFF757575)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF757575)
      ..style = PaintingStyle.fill;

    const towerWidth = 30.0;
    const towerHeight = 55.0;
    const levelSpacing = 13.0;

    // Main tower body
    final bodyRect = Rect.fromLTWH(
      center.dx - towerWidth / 2,
      center.dy - towerHeight / 2,
      towerWidth,
      towerHeight,
    );
    canvas.drawRect(bodyRect, strokePaint);

    // Tower levels/floors
    for (int i = 1; i < 4; i++) {
      final y = center.dy - towerHeight / 2 + (i * levelSpacing);
      canvas.drawLine(
        Offset(center.dx - towerWidth / 2, y),
        Offset(center.dx + towerWidth / 2, y),
        strokePaint,
      );
    }

    // Windows on tower
    _drawTowerWindows(canvas, center, towerWidth, towerHeight, fillPaint);

    // Flag on top of tower
    _drawFlagIcon(canvas, Offset(center.dx, center.dy - towerHeight / 2 - 10));

    // Base/ground support
    const groundOffset = 10.0;
    canvas.drawLine(
      Offset(
        center.dx - towerWidth / 2 - groundOffset,
        center.dy + towerHeight / 2,
      ),
      Offset(
        center.dx + towerWidth / 2 + groundOffset,
        center.dy + towerHeight / 2,
      ),
      strokePaint,
    );

    // Support legs
    final groundPaint = Paint()
      ..color = const Color(0xFF757575)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(
        center.dx - towerWidth / 2 - groundOffset,
        center.dy + towerHeight / 2,
      ),
      Offset(center.dx - towerWidth / 2, center.dy + towerHeight / 2 + 5),
      groundPaint,
    );

    canvas.drawLine(
      Offset(
        center.dx + towerWidth / 2 + groundOffset,
        center.dy + towerHeight / 2,
      ),
      Offset(center.dx + towerWidth / 2, center.dy + towerHeight / 2 + 5),
      groundPaint,
    );
  }

  void _drawTowerWindows(
    Canvas canvas,
    Offset center,
    double towerWidth,
    double towerHeight,
    Paint fillPaint,
  ) {
    const windowSize = 5.5;
    const windowGap = 13.0;
    const leftColumnX = -8.0;
    const rightColumnX = 4.5;

    for (int i = 0; i < 3; i++) {
      final y = center.dy - towerHeight / 2 + 12 + (i * windowGap);

      // Left window
      canvas.drawRect(
        Rect.fromLTWH(center.dx + leftColumnX, y, windowSize, windowSize),
        fillPaint,
      );

      // Right window
      canvas.drawRect(
        Rect.fromLTWH(center.dx + rightColumnX, y, windowSize, windowSize),
        fillPaint,
      );
    }
  }

  void _drawFlagIcon(Canvas canvas, Offset position) {
    final flagPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final polePaint = Paint()
      ..color = const Color(0xFF757575)
      ..strokeWidth = 1.5;

    // Flag pole
    canvas.drawLine(position, Offset(position.dx, position.dy - 13), polePaint);

    // Flag triangle
    final flagPath = Path()
      ..moveTo(position.dx, position.dy - 13)
      ..lineTo(position.dx + 10, position.dy - 10)
      ..lineTo(position.dx + 10, position.dy - 6)
      ..lineTo(position.dx, position.dy - 9)
      ..close();

    canvas.drawPath(flagPath, flagPaint);
  }

  void _drawCheckmarkIcon(Canvas canvas, Offset center) {
    final checkPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const checkY = 25.0;
    const checkWidth = 14.0;

    final checkPath = Path()
      ..moveTo(center.dx - checkWidth / 4, center.dy + checkY + 2)
      ..lineTo(center.dx - 2, center.dy + checkY + 6)
      ..lineTo(center.dx + checkWidth / 3, center.dy + checkY - 3);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(BestRoutesIconPainter oldDelegate) =>
      oldDelegate.rotationValue != rotationValue ||
      oldDelegate.pulseValue != pulseValue;
}
