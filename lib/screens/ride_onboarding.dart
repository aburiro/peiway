import 'package:flutter/material.dart';
import 'dart:math';

class RideOnboarding extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const RideOnboarding({
    Key? key,
    this.currentPage = 2,
    this.totalPages = 3,
    this.onNext,
    this.onSkip,
  }) : super(key: key);

  @override
  State<RideOnboarding> createState() => _RideOnboardingState();
}

class _RideOnboardingState extends State<RideOnboarding>
    with TickerProviderStateMixin {
  late AnimationController _heartsController;
  late AnimationController _batteryController;
  late AnimationController _scooterController;

  @override
  void initState() {
    super.initState();

    _heartsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _batteryController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scooterController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _heartsController.dispose();
    _batteryController.dispose();
    _scooterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main Icon Section
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Floating hearts background
                    _buildFloatingHearts(),
                    // Main ride icon
                    _buildRideIcon(),
                  ],
                ),
              ),
            ),
            // Text Content
            _buildTextSection(),
            // Page Indicators
            _buildPageIndicators(),
            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingHearts() {
    return AnimatedBuilder(
      animation: _heartsController,
      builder: (context, child) {
        final float = sin(_heartsController.value * pi * 2) * 12;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Top-left heart (filled)
            Positioned(
              left: -70,
              top: -80 + float,
              child: _heartWidget(size: 28, isFilled: true),
            ),
            // Top-right heart (outline)
            Positioned(
              right: -60,
              top: -60 + float * 0.8,
              child: _heartWidget(size: 24, isFilled: false),
            ),
            // Bottom-right heart (outline)
            Positioned(
              right: -50,
              bottom: -40 + float * 0.6,
              child: _heartWidget(size: 20, isFilled: false),
            ),
          ],
        );
      },
    );
  }

  Widget _heartWidget({required double size, required bool isFilled}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: HeartIconPainter(
          isFilled: isFilled,
          color: const Color(0xFF4CAF50),
        ),
      ),
    );
  }

  Widget _buildRideIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_batteryController, _scooterController]),
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (_batteryController.value * 0.08),
          child: CustomPaint(
            painter: RideIconPainter(
              batteryLevel: 0.3 + (_batteryController.value * 0.7),
              scooterTilt: sin(_scooterController.value * pi * 2) * 0.02,
            ),
            size: const Size(240, 240),
          ),
        );
      },
    );
  }

  Widget _buildTextSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          Text(
            'Ride',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF424242),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy eco-friendly rides with instant charging',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF9E9E9E),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.totalPages,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            width: index == widget.currentPage ? 10 : 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == widget.currentPage
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE0E0E0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.onSkip ?? () => Navigator.pop(context),
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
            onTap: widget.onNext ?? () {},
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
    );
  }
}

class HeartIconPainter extends CustomPainter {
  final bool isFilled;
  final Color color;

  HeartIconPainter({required this.isFilled, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Heart shape using cubic bezier curves
    path.moveTo(width * 0.5, height * 0.4);

    // Left lobe
    path.cubicTo(width * 0.2, height * 0.1, 0, height * 0.2, 0, height * 0.35);
    path.cubicTo(
      0,
      height * 0.65,
      width * 0.25,
      height * 0.95,
      width * 0.5,
      height,
    );

    // Right lobe
    path.cubicTo(
      width * 0.75,
      height * 0.95,
      width,
      height * 0.65,
      width,
      height * 0.35,
    );
    path.cubicTo(
      width,
      height * 0.2,
      width * 0.8,
      height * 0.1,
      width * 0.5,
      height * 0.4,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HeartIconPainter oldDelegate) =>
      oldDelegate.isFilled != isFilled;
}

class RideIconPainter extends CustomPainter {
  final double batteryLevel;
  final double scooterTilt;

  RideIconPainter({required this.batteryLevel, required this.scooterTilt});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw charging station
    _drawChargingStation(canvas, center);

    // Draw scooter
    _drawScooter(canvas, center);

    // Draw cable connecting them
    _drawChargingCable(canvas, center);
  }

  void _drawChargingStation(Canvas canvas, Offset center) {
    final outline = Paint()
      ..color = const Color(0xFF757575)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillGreen = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    const stationX = -20.0;
    const stationW = 28.0;
    const stationH = 52.0;

    // Main station body
    final bodyRect = Rect.fromLTWH(
      center.dx + stationX,
      center.dy - stationH / 2 - 8,
      stationW,
      stationH,
    );
    canvas.drawRect(bodyRect, outline);

    // Display screen area
    final screenRect = Rect.fromLTWH(
      center.dx + stationX + 4,
      center.dy - stationH / 2,
      20,
      16,
    );
    canvas.drawRect(screenRect, outline);

    // Lightning bolt in display
    _drawLightning(
      canvas,
      Offset(center.dx + stationX + 14, center.dy - stationH / 2 + 8),
    );

    // Battery display section
    final batteryDisplayRect = Rect.fromLTWH(
      center.dx + stationX + 5,
      center.dy - stationH / 2 + 22,
      18,
      7,
    );
    canvas.drawRect(batteryDisplayRect, outline);

    // Battery level fill (animated)
    final batteryFillRect = Rect.fromLTWH(
      center.dx + stationX + 6,
      center.dy - stationH / 2 + 23,
      16 * batteryLevel,
      5,
    );
    canvas.drawRect(batteryFillRect, fillGreen);

    // Charging port on left side
    canvas.drawCircle(
      Offset(center.dx + stationX - 2, center.dy - 4),
      3.5,
      outline,
    );

    // Port indicator
    canvas.drawCircle(
      Offset(center.dx + stationX - 2, center.dy - 4),
      2,
      fillGreen,
    );

    // Cable from port
    canvas.drawLine(
      Offset(center.dx + stationX - 2, center.dy),
      Offset(center.dx + stationX - 5, center.dy + 20),
      outline,
    );
  }

  void _drawLightning(Canvas canvas, Offset pos) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(pos.dx, pos.dy - 4)
      ..lineTo(pos.dx - 2, pos.dy - 1)
      ..lineTo(pos.dx - 1, pos.dy)
      ..lineTo(pos.dx - 3, pos.dy + 4)
      ..lineTo(pos.dx + 2, pos.dy + 1)
      ..lineTo(pos.dx + 1, pos.dy - 1)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawChargingCable(Canvas canvas, Offset center) {
    final cablePaint = Paint()
      ..color = const Color(0xFF757575)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Curve from station to scooter
    final cablePath = Path()
      ..moveTo(center.dx - 22, center.dy + 12)
      ..quadraticBezierTo(
        center.dx - 5,
        center.dy + 28,
        center.dx + 15,
        center.dy + 38,
      );

    canvas.drawPath(cablePath, cablePaint);
  }

  void _drawScooter(Canvas canvas, Offset center) {
    final outline = Paint()
      ..color = const Color(0xFF757575)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fill = Paint()
      ..color = const Color(0xFF757575)
      ..style = PaintingStyle.fill;

    const scooterX = 18.0;
    const scooterY = 38.0;

    // Save canvas and apply tilt
    canvas.save();
    canvas.translate(center.dx + scooterX, center.dy + scooterY);
    canvas.rotate(scooterTilt);

    // Scooter deck/platform
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-14, -3, 28, 6),
        const Radius.circular(2),
      ),
      outline,
    );

    // Handlebar pole
    canvas.drawLine(const Offset(-2, -3), const Offset(-2, -18), outline);

    // Handlebar grip
    canvas.drawCircle(const Offset(-2, -18), 3.5, outline);
    canvas.drawCircle(const Offset(-2, -18), 2, fill);

    // Front wheel
    canvas.drawCircle(const Offset(14, 5), 7.5, outline);
    canvas.drawCircle(
      const Offset(14, 5),
      5.5,
      fill..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(const Offset(14, 5), 3, fill..style = PaintingStyle.fill);

    // Back wheel
    canvas.drawCircle(const Offset(-14, 5), 7.5, outline);
    canvas.drawCircle(
      const Offset(-14, 5),
      5.5,
      fill..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      const Offset(-14, 5),
      3,
      fill..style = PaintingStyle.fill,
    );

    // Rider figure
    canvas.drawCircle(const Offset(-5, -14), 2.5, fill);
    canvas.drawLine(const Offset(-5, -11), const Offset(-5, 2), outline);

    canvas.restore();
  }

  @override
  bool shouldRepaint(RideIconPainter oldDelegate) =>
      oldDelegate.batteryLevel != batteryLevel ||
      oldDelegate.scooterTilt != scooterTilt;
}
