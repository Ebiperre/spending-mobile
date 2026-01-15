import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:spending_mobile/screens/dashboard_screen.dart';
import 'package:spending_mobile/utils/app_theme.dart';

class Step5Welcome extends StatefulWidget {
  const Step5Welcome({super.key});

  @override
  State<Step5Welcome> createState() => _Step5WelcomeState();
}

class _Step5WelcomeState extends State<Step5Welcome> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _confettiController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkSurface,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Progress indicator - all complete
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Row(
                    children: List.generate(5, (index) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                        child: _buildProgressBar(),
                      ),
                    )),
                  ),
                ),

                const SizedBox(height: 8),

                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 600),
                  child: const Text(
                    'Complete!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey400,
                    ),
                  ),
                ),

                const Spacer(),

                // Success Icon with pulse animation
                ZoomIn(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 800),
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '🎉',
                          style: TextStyle(fontSize: 72),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Welcome Message with bounce
                ElasticIn(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 1000),
                  child: const Text(
                    'You\'re All Set!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                FadeIn(
                  delay: const Duration(milliseconds: 900),
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Your budget is ready. Let\'s keep your spending cool!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 48),

                // Feature Cards with staggered animation
                _buildAnimatedFeatureCard(
                  icon: Icons.device_thermostat,
                  title: 'Temperature Tracking',
                  description: 'See how hot your spending is',
                  delay: 1100,
                ),

                const SizedBox(height: 12),

                _buildAnimatedFeatureCard(
                  icon: Icons.bolt,
                  title: '10-Second Check-Ins',
                  description: 'Quick daily updates, no stress',
                  delay: 1250,
                ),

                const SizedBox(height: 12),

                _buildAnimatedFeatureCard(
                  icon: Icons.notifications_active,
                  title: 'Smart Alerts',
                  description: 'We warn you before money finish!',
                  delay: 1400,
                ),

                const Spacer(),

                // Get Started Button with bounce
                BounceInUp(
                  delay: const Duration(milliseconds: 1600),
                  duration: const Duration(milliseconds: 800),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const DashboardScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.1),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  )),
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildAnimatedFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return FadeInRight(
      delay: Duration(milliseconds: delay),
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.7),
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
