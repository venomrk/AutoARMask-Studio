import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/backend_service.dart';

class LivePreview extends StatefulWidget {
  final bool isRunning;
  final BackendService backendService;

  const LivePreview({
    super.key,
    required this.isRunning,
    required this.backendService,
  });

  @override
  State<LivePreview> createState() => _LivePreviewState();
}

class _LivePreviewState extends State<LivePreview> with SingleTickerProviderStateMixin {
  Uint8List? _currentFrame;
  late AnimationController _scanlineController;
  StreamSubscription? _frameSubscription;

  @override
  void initState() {
    super.initState();
    _scanlineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _frameSubscription = widget.backendService.frameStream.listen((frame) {
      if (mounted) {
        setState(() => _currentFrame = frame);
      }
    });
  }

  @override
  void dispose() {
    _scanlineController.dispose();
    _frameSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF0A0A0A),
        border: Border.all(
          color: widget.isRunning 
              ? const Color(0xFF4CAF50).withOpacity(0.5) 
              : Colors.white12,
          width: 2,
        ),
        boxShadow: widget.isRunning
            ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            Container(
              color: const Color(0xFF0A0A0A),
            ),
            // Video feed or placeholder
            _currentFrame != null
                ? Image.memory(
                    _currentFrame!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : _buildPlaceholder(),
            // Scanline effect overlay
            if (widget.isRunning)
              AnimatedBuilder(
                animation: _scanlineController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ScanlinePainter(_scanlineController.value),
                    size: Size.infinite,
                  );
                },
              ),
            // Corner brackets
            _buildCornerBrackets(),
            // Recording indicator
            if (widget.isRunning)
              Positioned(
                top: 10,
                left: 10,
                child: _buildRecordingIndicator(),
              ),
            // FPS counter
            if (widget.isRunning)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '60 FPS',
                    style: TextStyle(
                      color: const Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: 60,
            color: Colors.white24,
          ),
          const SizedBox(height: 15),
          Text(
            'Camera Inactive',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Click "Start Camera" to begin',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBrackets() {
    return IgnorePointer(
      child: CustomPaint(
        painter: CornerBracketsPainter(
          color: widget.isRunning 
              ? const Color(0xFF4CAF50) 
              : const Color(0xFFE53935).withOpacity(0.5),
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                  const Color(0xFFE53935),
                  const Color(0xFFE53935).withOpacity(0.3),
                  (value * 2 % 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE53935).withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'LIVE',
              style: TextStyle(
                color: const Color(0xFFE53935),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ScanlinePainter extends CustomPainter {
  final double progress;

  ScanlinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF4CAF50).withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromLTWH(0, progress * size.height - 50, size.width, 100),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, progress * size.height - 50, size.width, 100),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScanlinePainter oldDelegate) => oldDelegate.progress != progress;
}

class CornerBracketsPainter extends CustomPainter {
  final Color color;

  CornerBracketsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const bracketSize = 30.0;
    const offset = 15.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(offset, offset + bracketSize)
        ..lineTo(offset, offset)
        ..lineTo(offset + bracketSize, offset),
      paint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - offset - bracketSize, offset)
        ..lineTo(size.width - offset, offset)
        ..lineTo(size.width - offset, offset + bracketSize),
      paint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(offset, size.height - offset - bracketSize)
        ..lineTo(offset, size.height - offset)
        ..lineTo(offset + bracketSize, size.height - offset),
      paint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - offset - bracketSize, size.height - offset)
        ..lineTo(size.width - offset, size.height - offset)
        ..lineTo(size.width - offset, size.height - offset - bracketSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(CornerBracketsPainter oldDelegate) => oldDelegate.color != color;
}
