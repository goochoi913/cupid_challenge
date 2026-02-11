import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome> {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      // Replace the body: Column(...) with this:
      body: Container(
        // PART 2: Soft pink-to-red radial gradient
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFFF8BBD0), Color(0xFFE91E63)], // Pink to Red
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // We add a background to the dropdown so it's readable
            DropdownButton<String>(
              value: selectedEmoji,
              dropdownColor: Colors.white, 
              items: emojiOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => selectedEmoji = value ?? selectedEmoji),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: HeartEmojiPainter(type: selectedEmoji),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Heart base path
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10, center.dx + 60, center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120, center.dx - 110, center.dy - 10, center.dx, center.dy + 60)
      ..close();

    // LOVE TRAIL (Glowing Aura) ---
    final trailPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15 // Thick stroke for aura
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10); // Blur for glow effect
    canvas.drawPath(heartPath, trailPaint);

    // HEART GRADIENT ---
    final Rect heartBounds = heartPath.getBounds();
    final Gradient heartGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: type == 'Party Heart'
          ? [const Color(0xFFF48FB1), const Color(0xFFFFCC80)] 
          : [const Color(0xFFE91E63), const Color(0xFF880E4F)],
    );
    paint.shader = heartGradient.createShader(heartBounds);
    canvas.drawPath(heartPath, paint);

    // Face features
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30), 0, 3.14, false, mouthPaint);

    // Party Hat
    if (type == 'Party Heart') {
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);
    }

    // FESTIVE DETAILS & SPARKLES
    if (type == 'Party Heart') {
      final confettiPaint = Paint()..style = PaintingStyle.fill;
      
      // CONFETTI CIRCLES
      final List<Offset> circles = [
        Offset(center.dx - 70, center.dy - 60),
        Offset(center.dx + 50, center.dy - 100),
        Offset(center.dx - 90, center.dy),
      ];
      for (var pos in circles) {
        confettiPaint.color = Colors.cyanAccent;
        canvas.drawCircle(pos, 6, confettiPaint);
      }

      // CONFETTI TRIANGLES
      final triPaint = Paint()..color = Colors.amberAccent..style = PaintingStyle.fill;
      final List<Offset> triangles = [
        Offset(center.dx + 70, center.dy - 60),
        Offset(center.dx - 50, center.dy - 100),
        Offset(center.dx + 90, center.dy),
      ];
      for (var pos in triangles) {
        Path triPath = Path()
          ..moveTo(pos.dx, pos.dy - 5)
          ..lineTo(pos.dx + 5, pos.dy + 5)
          ..lineTo(pos.dx - 5, pos.dy + 5)
          ..close();
        canvas.drawPath(triPath, triPaint);
      }

      // ANIMATED SPARKLES (Star Bursts / Short Lines)
      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      // Draw a little burst near the hat
      double burstX = center.dx;
      double burstY = center.dy - 120;
      canvas.drawLine(Offset(burstX, burstY - 10), Offset(burstX, burstY - 20), linePaint); // Up
      canvas.drawLine(Offset(burstX - 10, burstY), Offset(burstX - 20, burstY), linePaint); // Left
      canvas.drawLine(Offset(burstX + 10, burstY), Offset(burstX + 20, burstY), linePaint); // Right
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) => oldDelegate.type != type;
}