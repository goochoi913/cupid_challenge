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

// CHANGED: Use TickerProviderStateMixin (not Single) to handle TWO animations
class _ValentineHomeState extends State<ValentineHome> with TickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';
  
  // Pulse Animation Variables
  late AnimationController _controller;
  bool isPulsing = false;

  // Balloon Animation Variables
  late AnimationController _balloonController;
  late Animation<Offset> _balloonAnimation;

  @override
  void initState() {
    super.initState();
    
    // 1. Setup Pulse Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.9,
      upperBound: 1.1,
    );

    // 2. Setup Balloon Animation (Falls from top to bottom)
    _balloonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _balloonAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5), // Start above screen
      end: const Offset(0, 1.5),   // End below screen
    ).animate(CurvedAnimation(parent: _balloonController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    _balloonController.dispose(); // Don't forget to dispose balloons!
    super.dispose();
  }

  void togglePulse() {
    setState(() {
      isPulsing = !isPulsing;
      if (isPulsing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cupid\'s Canvas'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/cupid.jpg'),
          ),
        ),
      ),
      // STACK allows us to layer Balloons ON TOP of everything else
      body: Stack(
        children: [
          // LAYER 1: The Main App Content (Gradient, Heart, Buttons)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFFF8BBD0), Color(0xFFE91E63)],
                center: Alignment.center,
                radius: 0.8,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                
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
                    child: ScaleTransition(
                      scale: _controller,
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter: HeartEmojiPainter(type: selectedEmoji),
                      ),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: togglePulse,
                      icon: Icon(isPulsing ? Icons.favorite : Icons.favorite_border),
                      label: Text(isPulsing ? "Stop Pulse" : "Pulse Heart"),
                    ),
                    
                    const SizedBox(width: 20),

                    // CELEBRATE BUTTON: Triggers the balloons
                    ElevatedButton.icon(
                      onPressed: () {
                         _balloonController.reset(); // Move back to top
                         _balloonController.forward(); // Drop them!
                      },
                      icon: const Icon(Icons.celebration),
                      label: const Text("Celebrate!"),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16), 

                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/heart_glitter.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.white.withOpacity(0.5), BlendMode.dstATop),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Happy Valentine's Day!",
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LAYER 2: The Falling Balloons (Invisible until button clicked)
          SlideTransition(
            position: _balloonAnimation,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.only(top: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Icon(Icons.circle, color: Colors.red, size: 40),
                    Icon(Icons.circle, color: Colors.blue, size: 50),
                    Icon(Icons.star, color: Colors.yellow, size: 60),
                    Icon(Icons.circle, color: Colors.purple, size: 40),
                    Icon(Icons.favorite, color: Colors.pink, size: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
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

    // LOVE TRAIL
    final trailPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(heartPath, trailPaint);

    // HEART GRADIENT
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

    // FESTIVE DETAILS
    if (type == 'Party Heart') {
      final confettiPaint = Paint()..style = PaintingStyle.fill;
      
      // Circles
      final List<Offset> circles = [
        Offset(center.dx - 70, center.dy - 60),
        Offset(center.dx + 50, center.dy - 100),
        Offset(center.dx - 90, center.dy),
      ];
      for (var pos in circles) {
        confettiPaint.color = Colors.cyanAccent;
        canvas.drawCircle(pos, 6, confettiPaint);
      }

      // Triangles
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

      // Sparkles
      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      double burstX = center.dx;
      double burstY = center.dy - 120;
      canvas.drawLine(Offset(burstX, burstY - 10), Offset(burstX, burstY - 20), linePaint);
      canvas.drawLine(Offset(burstX - 10, burstY), Offset(burstX - 20, burstY), linePaint);
      canvas.drawLine(Offset(burstX + 10, burstY), Offset(burstX + 20, burstY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) => oldDelegate.type != type;
}