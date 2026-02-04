import 'package:flutter/material.dart';
import 'dart:math';

class DiscoverOnboarding extends StatefulWidget {
  const DiscoverOnboarding({Key? key}) : super(key: key);

  @override
  State<DiscoverOnboarding> createState() => _DiscoverOnboardingState();
}

class _DiscoverOnboardingState extends State<DiscoverOnboarding> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingItem> items = [
    OnboardingItem(title: 'Discover', icon: CompassIcon()),
    OnboardingItem(title: 'Connect', icon: NetworkIcon()),
    OnboardingItem(title: 'Explore', icon: ExploreIcon()),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 250,
                        width: 250,
                        child: items[index].icon,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        items[index].title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  items.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == index ? 10 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFBDBDBD),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Navigation
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
                    onTap: () {
                      if (_currentPage < items.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushNamed(context, '/login_screen');
                      }
                    },
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

class OnboardingItem {
  final String title;
  final Widget icon;

  OnboardingItem({required this.title, required this.icon});
}

// Compass Icon
class CompassIcon extends StatelessWidget {
  const CompassIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: CompassPainter(), size: const Size(250, 250));
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2.2);
    final radius = 60.0;

    // Outer circle
    final circlePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, circlePaint);

    // Draw 8 direction lines
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * pi / 180;
      final start = Offset(
        center.dx + cos(angle) * (radius - 8),
        center.dy + sin(angle) * (radius - 8),
      );
      final end = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      canvas.drawLine(start, end, linePaint);
    }

    // Draw Chinese characters (东, 西, 南, 北)
    _drawText(canvas, '東', center, radius, 0);
    _drawText(canvas, '西', center, radius, 180);
    _drawText(canvas, '南', center, radius, 90);
    _drawText(canvas, '北', center, radius, 270);

    // Center dot
    final centerPaint = Paint()..color = Colors.black;
    canvas.drawCircle(center, 4, centerPaint);

    // Draw grass/ground
    final grassPaint = Paint()
      ..color = const Color(0xFF81C784)
      ..style = PaintingStyle.fill;

    // Grass base
    final grassPath = Path()
      ..moveTo(center.dx - 50, size.height - 20)
      ..quadraticBezierTo(
        center.dx - 40,
        size.height - 30,
        center.dx - 30,
        size.height - 20,
      )
      ..quadraticBezierTo(
        center.dx,
        size.height - 35,
        center.dx + 30,
        size.height - 20,
      )
      ..quadraticBezierTo(
        center.dx + 40,
        size.height - 30,
        center.dx + 50,
        size.height - 20,
      )
      ..lineTo(center.dx + 50, size.height)
      ..lineTo(center.dx - 50, size.height)
      ..close();

    canvas.drawPath(grassPath, grassPaint);

    // Draw clouds
    _drawCloud(canvas, Offset(size.width * 0.2, size.height * 0.1));
    _drawCloud(canvas, Offset(size.width * 0.8, size.height * 0.2));
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double radius,
    double angle,
  ) {
    final angleRad = angle * pi / 180;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final offset = Offset(
      center.dx + cos(angleRad) * (radius + 25) - textPainter.width / 2,
      center.dy + sin(angleRad) * (radius + 25) - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);
  }

  void _drawCloud(Canvas canvas, Offset position) {
    final paint = Paint()
      ..color = const Color(0xFFB0E0E6).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(position.dx, position.dy)
      ..cubicTo(
        position.dx - 15,
        position.dy - 10,
        position.dx - 20,
        position.dy - 5,
        position.dx - 15,
        position.dy + 5,
      )
      ..cubicTo(
        position.dx - 25,
        position.dy + 5,
        position.dx - 30,
        position.dy + 10,
        position.dx - 20,
        position.dy + 15,
      )
      ..cubicTo(
        position.dx,
        position.dy + 15,
        position.dx + 15,
        position.dy + 10,
        position.dx + 20,
        position.dy + 5,
      )
      ..cubicTo(
        position.dx + 25,
        position.dy,
        position.dx + 20,
        position.dy - 8,
        position.dx + 10,
        position.dy - 10,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CompassPainter oldDelegate) => false;
}

// Network Icon
class NetworkIcon extends StatelessWidget {
  const NetworkIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: NetworkPainter(), size: const Size(250, 250));
  }
}

class NetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final nodeStroke = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const nodeRadius = 8.0;
    const distances = [0.0, 70.0, 100.0];

    // Draw multiple circles of nodes
    for (int d = 1; d < distances.length; d++) {
      final distance = distances[d];
      final nodeCount = d == 1 ? 6 : 8;

      for (int i = 0; i < nodeCount; i++) {
        final angle = (i * 360 / nodeCount) * pi / 180;
        final x = center.dx + cos(angle) * distance;
        final y = center.dy + sin(angle) * distance;
        final nodePos = Offset(x, y);

        // Draw line to center
        if (d == 1) {
          canvas.drawLine(center, nodePos, linePaint);
        }

        // Draw node
        canvas.drawCircle(nodePos, nodeRadius, nodePaint);
        canvas.drawCircle(nodePos, nodeRadius, nodeStroke);
      }
    }

    // Center node
    canvas.drawCircle(center, nodeRadius + 2, nodePaint);
    canvas.drawCircle(center, nodeRadius + 2, nodeStroke);
  }

  @override
  bool shouldRepaint(NetworkPainter oldDelegate) => false;
}

// Explore Icon
class ExploreIcon extends StatelessWidget {
  const ExploreIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: ExplorePainter(), size: const Size(250, 250));
  }
}

class ExplorePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2.2);

    final mapPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw map grid
    const mapWidth = 100.0;
    const mapHeight = 80.0;
    final left = center.dx - mapWidth / 2;
    final top = center.dy - mapHeight / 2;
    final right = center.dx + mapWidth / 2;
    const bottom = mapHeight;

    // Grid lines
    for (int i = 0; i < 5; i++) {
      final x = left + (mapWidth / 4) * i;
      canvas.drawLine(Offset(x, top), Offset(x, top + bottom), mapPaint);
    }

    for (int i = 0; i < 4; i++) {
      final y = top + (bottom / 3) * i;
      canvas.drawLine(Offset(left, y), Offset(right, y), mapPaint);
    }

    // Marker pin
    final pinPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, pinPaint);
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx - 6, center.dy + 12)
        ..cubicTo(
          center.dx - 6,
          center.dy + 12,
          center.dx,
          center.dy + 16,
          center.dx,
          center.dy + 16,
        )
        ..cubicTo(
          center.dx,
          center.dy + 16,
          center.dx + 6,
          center.dy + 12,
          center.dx + 6,
          center.dy + 12,
        )
        ..lineTo(center.dx, center.dy)
        ..close(),
      pinPaint,
    );
  }

  @override
  bool shouldRepaint(ExplorePainter oldDelegate) => false;
}
