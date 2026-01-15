import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final String status;
  final String virtualCameraName;

  const StatusBar({
    super.key,
    required this.status,
    required this.virtualCameraName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF151515),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE53935).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status.contains('Ready') || status.contains('success') 
                    ? const Color(0xFF4CAF50) 
                    : const Color(0xFFFFEB3B),
                boxShadow: [
                  BoxShadow(
                    color: (status.contains('Ready') || status.contains('success') 
                        ? const Color(0xFF4CAF50) 
                        : const Color(0xFFFFEB3B)).withOpacity(0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Status: ',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
            Text(
              status,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            // Virtual camera output
            Row(
              children: [
                Icon(
                  Icons.videocam,
                  color: const Color(0xFFE53935),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Output: ',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                Text(
                  virtualCameraName,
                  style: TextStyle(
                    color: const Color(0xFFE53935),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
