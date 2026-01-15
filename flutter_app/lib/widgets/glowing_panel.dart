import 'package:flutter/material.dart';

class GlowingPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final AnimationController glowController;

  const GlowingPanel({
    super.key,
    required this.title,
    required this.child,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E1E1E),
                const Color(0xFF151515),
              ],
            ),
            border: Border.all(
              color: Color.lerp(
                const Color(0xFF333333),
                const Color(0xFFE53935).withOpacity(0.5),
                glowController.value * 0.3,
              )!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE53935).withOpacity(0.1 + glowController.value * 0.1),
                blurRadius: 20,
                spreadRadius: -5,
              ),
              // Corner glow effects
              BoxShadow(
                color: const Color(0xFFE53935).withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(-2, -2),
                spreadRadius: -10,
              ),
              BoxShadow(
                color: const Color(0xFFE53935).withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(2, 2),
                spreadRadius: -10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: [
                // Title bar with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2A2A2A),
                        const Color(0xFF1A1A1A),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFE53935).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE53935),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFFE53935).withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
