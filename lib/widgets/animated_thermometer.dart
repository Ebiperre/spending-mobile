import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedThermometer extends StatefulWidget {
  final double percentage;
  final double width;
  final double height;

  const AnimatedThermometer({
    super.key,
    required this.percentage,
    this.width = 120,
    this.height = 300,
  });

  @override
  State<AnimatedThermometer> createState() => _AnimatedThermometerState();
}

class _AnimatedThermometerState extends State<AnimatedThermometer>
    with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _fillAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  Color get thermometerColor {
    if (widget.percentage < 0.3) return Colors.green;
    if (widget.percentage < 0.6) return Colors.orange;
    return Colors.red;
  }

  String get status {
    if (widget.percentage < 0.3) return 'Cool & Calm ❄️';
    if (widget.percentage < 0.6) return 'Getting Warm 🌤️';
    return 'Hot Hot! 🔥';
  }

  @override
  void initState() {
    super.initState();

    // Fill animation - smooth mercury rise
    _fillController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: widget.percentage,
    ).animate(CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeInOutCubic,
    ));

    // Pulse animation - heartbeat effect for hot temperatures
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Shimmer animation - light reflection
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fillController.forward();
    _shimmerController.repeat();

    if (widget.percentage >= 0.6) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _fillController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _fillAnimation,
        _pulseAnimation,
        _shimmerAnimation,
      ]),
      builder: (context, child) {
        return Column(
          children: [
            // Animated Status Text
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: thermometerColor,
                        shadows: widget.percentage >= 0.6
                            ? [
                                Shadow(
                                  color: thermometerColor.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Thermometer with pulse effect
            Transform.scale(
              scale: widget.percentage >= 0.6 ? _pulseAnimation.value : 1.0,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(widget.width / 2),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: thermometerColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Temperature scale markers
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 2,
                                  width: 30,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),

                    // Filled mercury with gradient and shimmer
                    ClipRRect(
                      borderRadius: BorderRadius.circular(widget.width / 2),
                      child: Stack(
                        children: [
                          // Main mercury fill
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 2000),
                            curve: Curves.easeInOutCubic,
                            height: (widget.height - 20) * _fillAnimation.value,
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  thermometerColor,
                                  thermometerColor.withOpacity(0.8),
                                  thermometerColor.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(widget.width / 2),
                            ),
                          ),

                          // Shimmer effect
                          if (_fillAnimation.value > 0)
                            Positioned.fill(
                              child: Transform.translate(
                                offset: Offset(0, _shimmerAnimation.value * widget.height),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Bubbles effect for hot temperatures
                          if (widget.percentage >= 0.6)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: BubblePainter(
                                  fillPercentage: _fillAnimation.value,
                                  animationValue: _shimmerAnimation.value,
                                  color: thermometerColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Bulb at bottom with glow effect
                    Positioned(
                      bottom: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: thermometerColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: thermometerColor.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: TweenAnimationBuilder<int>(
                            duration: const Duration(milliseconds: 2000),
                            tween: IntTween(
                              begin: 0,
                              end: (widget.percentage * 100).toInt(),
                            ),
                            curve: Curves.easeInOutCubic,
                            builder: (context, value, child) {
                              return Text(
                                '$value%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Steam/smoke effect for very hot
                    if (widget.percentage >= 0.8)
                      Positioned(
                        top: -10,
                        child: CustomPaint(
                          size: const Size(60, 60),
                          painter: SteamPainter(
                            animationValue: _shimmerAnimation.value,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class BubblePainter extends CustomPainter {
  final double fillPercentage;
  final double animationValue;
  final Color color;

  BubblePainter({
    required this.fillPercentage,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Draw animated bubbles
    for (int i = 0; i < 5; i++) {
      final offset = (animationValue + i * 0.3) % 1.0;
      final y = size.height - (size.height * fillPercentage) + (offset * size.height * fillPercentage);
      final x = size.width * 0.3 + (math.sin(offset * math.pi * 4 + i) * size.width * 0.2);
      final radius = 3.0 + (math.sin(offset * math.pi * 2) * 2);

      if (y > size.height - (size.height * fillPercentage) && y < size.height) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) => true;
}

class SteamPainter extends CustomPainter {
  final double animationValue;

  SteamPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw steam particles
    for (int i = 0; i < 3; i++) {
      final offset = (animationValue + i * 0.3) % 1.0;
      final y = size.height * offset;
      final x = size.width * 0.5 + (math.sin(offset * math.pi * 4) * size.width * 0.2);
      final radius = 10.0 * (1 - offset);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = Colors.grey.withOpacity(0.3 * (1 - offset)),
      );
    }
  }

  @override
  bool shouldRepaint(SteamPainter oldDelegate) => true;
}
