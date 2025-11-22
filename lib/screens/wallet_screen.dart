import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final percentage = 0.65; // 65% spent
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: Text(
                'Spending Thermometer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),

            const SizedBox(height: 8),

            FadeInDown(
              delay: const Duration(milliseconds: 50),
              duration: const Duration(milliseconds: 400),
              child: Text(
                '12 days until payday',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Main Thermometer Card
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Status indicator at top
                    FadeIn(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: _getGradientForPercentage(percentage),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _getColorForPercentage(percentage).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getEmojiForPercentage(percentage),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getStatusForPercentage(percentage),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Modern Thermometer
                    _ModernThermometer(percentage: percentage),

                    const SizedBox(height: 32),

                    // Animated Percentage
                    FadeIn(
                      delay: const Duration(milliseconds: 800),
                      duration: const Duration(milliseconds: 400),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: percentage * 100),
                        duration: const Duration(milliseconds: 1800),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -2,
                              foreground: Paint()
                                ..shader = _getGradientForPercentage(percentage).createShader(
                                  const Rect.fromLTWH(0, 0, 200, 70),
                                ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    FadeIn(
                      delay: const Duration(milliseconds: 1000),
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        _getMessageForPercentage(percentage),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Spent and Remaining
                    FadeInUp(
                      delay: const Duration(milliseconds: 1200),
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Spent',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1950.0),
                                    duration: const Duration(milliseconds: 1800),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Text(
                                        '\$${value.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                          color: Color(0xFFEF4444),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.grey.shade300.withOpacity(0.0),
                                    Colors.grey.shade300,
                                    Colors.grey.shade300.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Remaining',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1050.0),
                                    duration: const Duration(milliseconds: 1800),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Text(
                                        '\$${value.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                          color: Color(0xFF10B981),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Daily Budget Card
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.today,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Safe to spend today',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '\$87.50',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Insights Section
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              duration: const Duration(milliseconds: 400),
              child: Text(
                'Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Insight Cards
            FadeInUp(
              delay: const Duration(milliseconds: 350),
              duration: const Duration(milliseconds: 400),
              child: _buildInsightCard(
                context,
                icon: Icons.trending_up,
                title: 'Spending Pace',
                description: 'You\'re spending faster than last month',
                color: const Color(0xFFF97316),
                isDark: isDark,
              ),
            ),

            const SizedBox(height: 12),

            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 400),
              child: _buildInsightCard(
                context,
                icon: Icons.calendar_month,
                title: 'Days Remaining',
                description: '12 days to make \$1,050 last',
                color: const Color(0xFF6366F1),
                isDark: isDark,
              ),
            ),

            const SizedBox(height: 12),

            FadeInUp(
              delay: const Duration(milliseconds: 450),
              duration: const Duration(milliseconds: 400),
              child: _buildInsightCard(
                context,
                icon: Icons.lightbulb_outline,
                title: 'Daily Target',
                description: 'Try to spend less than \$87.50 per day',
                color: const Color(0xFF10B981),
                isDark: isDark,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradientForPercentage(double percentage) {
    if (percentage < 0.3) {
      return const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (percentage < 0.6) {
      return const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFFF97316), Color(0xFFEF4444)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage < 0.3) {
      return const Color(0xFF10B981);
    } else if (percentage < 0.6) {
      return const Color(0xFFF97316);
    } else {
      return const Color(0xFFEF4444);
    }
  }

  String _getEmojiForPercentage(double percentage) {
    if (percentage < 0.3) {
      return '❄️';
    } else if (percentage < 0.6) {
      return '🌤️';
    } else {
      return '🔥';
    }
  }

  String _getStatusForPercentage(double percentage) {
    if (percentage < 0.3) {
      return 'Cool & Calm';
    } else if (percentage < 0.6) {
      return 'Getting Warm';
    } else {
      return 'Hot Hot!';
    }
  }

  String _getMessageForPercentage(double percentage) {
    if (percentage < 0.3) {
      return 'You dey do well! Keep am up! 💪';
    } else if (percentage < 0.6) {
      return 'E dey warm small. Watch your spending o!';
    } else {
      return 'Brother/Sister, e don hot! Cool down the spending abeg! 🙏';
    }
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Thermometer Widget with smooth animations
class _ModernThermometer extends StatelessWidget {
  final double percentage;

  const _ModernThermometer({required this.percentage});

  Color _getColorForPercentage(double percentage) {
    if (percentage < 0.3) {
      return const Color(0xFF10B981);
    } else if (percentage < 0.6) {
      return const Color(0xFFF97316);
    } else {
      return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForPercentage(percentage);

    return Center(
      child: SizedBox(
        width: 100,
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main thermometer tube
            Positioned(
              top: 20,
              child: Container(
                width: 60,
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 3,
                  ),
                ),
              ),
            ),

            // Temperature scale marks
            Positioned(
              top: 20,
              child: SizedBox(
                width: 60,
                height: 260,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 15,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          Container(
                            width: 15,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),

            // Animated mercury fill
            Positioned(
              bottom: 70,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: percentage),
                duration: const Duration(milliseconds: 1800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Container(
                    width: 48,
                    height: 210 * value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          color,
                          color.withOpacity(0.8),
                          color.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bulb at bottom with glow effect
            Positioned(
              bottom: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            color,
                            color.withOpacity(0.9),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: percentage * 100),
                          duration: const Duration(milliseconds: 1800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Text(
                              '${value.toInt()}°',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Shine effect on tube
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                width: 20,
                height: 260,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
