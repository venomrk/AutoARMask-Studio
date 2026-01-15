import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glowing_panel.dart';
import '../widgets/style_selector.dart';
import '../widgets/live_preview.dart';
import '../widgets/status_bar.dart';
import '../services/backend_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final BackendService _backend = BackendService();
  
  Uint8List? _uploadedImage;
  String _selectedStyle = 'Qin Shi Huang';
  bool _isCameraRunning = false;
  bool _isGenerating = false;
  bool _virtualCameraActive = false;
  bool _connectedToOBS = false;
  String _status = 'Ready...';
  
  late AnimationController _pulseController;
  late AnimationController _glowController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _initBackend();
  }
  
  Future<void> _initBackend() async {
    await _backend.connect();
    _backend.statusStream.listen((status) {
      setState(() {
        _virtualCameraActive = status['camera_active'] ?? false;
        _connectedToOBS = status['obs_connected'] ?? false;
        _status = status['message'] ?? 'Ready...';
      });
    });
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _backend.disconnect();
    super.dispose();
  }
  
  Future<void> _uploadPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _uploadedImage = result.files.single.bytes;
        _status = 'Photo uploaded successfully';
      });
    }
  }
  
  Future<void> _generateMask() async {
    if (_uploadedImage == null) {
      setState(() => _status = 'Please upload a photo first');
      return;
    }
    
    setState(() {
      _isGenerating = true;
      _status = 'Generating mask...';
    });
    
    await _backend.generateMask(_uploadedImage!, _selectedStyle);
    
    setState(() {
      _isGenerating = false;
      _status = 'Mask generated successfully';
    });
  }
  
  void _toggleCamera() async {
    if (_isCameraRunning) {
      await _backend.stopCamera();
    } else {
      await _backend.startCamera();
    }
    setState(() => _isCameraRunning = !_isCameraRunning);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0A0A),
              const Color(0xFF1A0A0A),
              const Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Left Panel - Upload Photo
                    Expanded(
                      flex: 2,
                      child: _buildUploadPanel(),
                    ),
                    const SizedBox(width: 20),
                    // Center Panel - Style Selector
                    Expanded(
                      flex: 3,
                      child: _buildStylePanel(),
                    ),
                    const SizedBox(width: 20),
                    // Right Panel - Live Preview
                    Expanded(
                      flex: 3,
                      child: _buildPreviewPanel(),
                    ),
                  ],
                ),
              ),
            ),
            _buildControlBar(),
            StatusBar(
              status: _status,
              virtualCameraName: 'AutoARMaskCam',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF2A1A1A),
            const Color(0xFF1A1A1A),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE53935).withOpacity(0.5),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE53935), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.view_in_ar,
                color: const Color(0xFFE53935),
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              'AutoARMask',
              style: GoogleFonts.orbitron(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              ' Studio',
              style: GoogleFonts.orbitron(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
              ),
            ),
            const Spacer(),
            // Status Indicators
            _buildStatusIndicator(
              'Virtual Camera:',
              _virtualCameraActive ? 'Active' : 'Inactive',
              _virtualCameraActive,
            ),
            const SizedBox(width: 30),
            _buildStatusIndicator(
              'Connected to OBS',
              '',
              _connectedToOBS,
              showCheckmark: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusIndicator(String label, String value, bool isActive, {bool showCheckmark = false}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF4CAF50) : const Color(0xFF757575),
            boxShadow: isActive ? [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ] : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              color: isActive ? const Color(0xFF4CAF50) : Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        if (showCheckmark && isActive) ...[
          const SizedBox(width: 5),
          Icon(Icons.check, color: const Color(0xFF4CAF50), size: 18),
        ],
      ],
    );
  }
  
  Widget _buildUploadPanel() {
    return GlowingPanel(
      title: 'Upload Photo',
      glowController: _glowController,
      child: Center(
        child: GestureDetector(
          onTap: _uploadPhoto,
          child: Container(
            width: 150,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white24,
                width: 2,
              ),
            ),
            child: _uploadedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      _uploadedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_alt_1,
                        size: 50,
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Click to Upload Image',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStylePanel() {
    return GlowingPanel(
      title: 'Select Style',
      glowController: _glowController,
      child: Column(
        children: [
          StyleSelector(
            selectedStyle: _selectedStyle,
            onStyleChanged: (style) => setState(() => _selectedStyle = style),
          ),
          const Spacer(),
          _buildGenerateButton(),
        ],
      ),
    );
  }
  
  Widget _buildGenerateButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFB71C1C),
                const Color(0xFFE53935),
                const Color(0xFFB71C1C),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE53935).withOpacity(0.3 + _pulseController.value * 0.3),
                blurRadius: 15 + _pulseController.value * 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isGenerating ? null : _generateMask,
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: _isGenerating
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'GENERATE MASK',
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPreviewPanel() {
    return GlowingPanel(
      title: 'Live Preview',
      glowController: _glowController,
      child: LivePreview(
        isRunning: _isCameraRunning,
        backendService: _backend,
      ),
    );
  }
  
  Widget _buildControlBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            icon: Icons.play_arrow,
            label: 'Start Camera',
            isActive: !_isCameraRunning,
            onTap: _isCameraRunning ? null : _toggleCamera,
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            icon: Icons.stop,
            label: 'Stop Camera',
            isActive: _isCameraRunning,
            isDestructive: true,
            onTap: _isCameraRunning ? _toggleCamera : null,
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final color = isDestructive ? const Color(0xFFE53935) : Colors.white;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? color.withOpacity(0.5) : Colors.white24,
          width: 2,
        ),
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2A2A2A),
                  const Color(0xFF1A1A1A),
                ],
              )
            : null,
        color: isActive ? null : const Color(0xFF1A1A1A),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? color : Colors.white38,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? color : Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
