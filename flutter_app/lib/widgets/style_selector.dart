import 'package:flutter/material.dart';

class StyleSelector extends StatelessWidget {
  final String selectedStyle;
  final Function(String) onStyleChanged;

  const StyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onStyleChanged,
  });

  static const List<Map<String, dynamic>> styles = [
    {
      'name': 'Qin Shi Huang',
      'icon': Icons.shield,
      'color': Color(0xFFFFD700),
      'description': 'Ancient Emperor',
    },
    {
      'name': 'Anime',
      'icon': Icons.auto_awesome,
      'color': Color(0xFFFF69B4),
      'description': 'Cartoon Style',
    },
    {
      'name': 'Cinematic',
      'icon': Icons.movie,
      'color': Color(0xFF4169E1),
      'description': 'Movie Look',
    },
    {
      'name': 'Realistic',
      'icon': Icons.face,
      'color': Color(0xFF32CD32),
      'description': 'Photorealistic',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Style Tabs
        Container(
          height: 40,
          child: Row(
            children: styles.map((style) {
              final isSelected = selectedStyle == style['name'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onStyleChanged(style['name']),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                const Color(0xFFB71C1C),
                                const Color(0xFFE53935),
                              ],
                            )
                          : null,
                      color: isSelected ? null : const Color(0xFF2A2A2A),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFFE53935) 
                            : Colors.white12,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        style['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        // Avatar Grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildAvatarCard(styles[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarCard(Map<String, dynamic> style, int index) {
    final isSelected = selectedStyle == style['name'];
    
    return GestureDetector(
      onTap: () => onStyleChanged(style['name']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2A2A2A),
              const Color(0xFF1A1A1A),
            ],
          ),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFE53935) 
                : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE53935).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Placeholder avatar with gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      (style['color'] as Color).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      style['icon'],
                      size: 48,
                      color: style['color'],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      style['description'],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Selection overlay
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE53935),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
