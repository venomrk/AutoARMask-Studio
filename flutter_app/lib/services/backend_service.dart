import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class BackendService {
  static const String _baseUrl = 'http://localhost:8765';
  static const String _wsUrl = 'ws://localhost:8765/ws';
  
  WebSocketChannel? _channel;
  bool _isConnected = false;
  
  final StreamController<Uint8List> _frameController = StreamController<Uint8List>.broadcast();
  final StreamController<Map<String, dynamic>> _statusController = StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Uint8List> get frameStream => _frameController.stream;
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;
  bool get isConnected => _isConnected;
  
  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _isConnected = true;
      
      _channel!.stream.listen(
        (data) {
          if (data is List<int>) {
            // Binary frame data
            _frameController.add(Uint8List.fromList(data));
          } else if (data is String) {
            // JSON status message
            try {
              final json = jsonDecode(data);
              _statusController.add(json);
            } catch (_) {}
          }
        },
        onError: (error) {
          _isConnected = false;
          _statusController.add({
            'camera_active': false,
            'obs_connected': false,
            'message': 'Connection error',
          });
        },
        onDone: () {
          _isConnected = false;
        },
      );
      
      _statusController.add({
        'camera_active': false,
        'obs_connected': false,
        'message': 'Ready...',
      });
    } catch (e) {
      _isConnected = false;
      _statusController.add({
        'camera_active': false,
        'obs_connected': false,
        'message': 'Backend not running - Start the Python backend',
      });
    }
  }
  
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }
  
  Future<void> startCamera() async {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode({'action': 'start_camera'}));
    } else {
      // Try HTTP fallback
      try {
        await http.post(Uri.parse('$_baseUrl/start'));
      } catch (_) {}
    }
  }
  
  Future<void> stopCamera() async {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode({'action': 'stop_camera'}));
    } else {
      try {
        await http.post(Uri.parse('$_baseUrl/stop'));
      } catch (_) {}
    }
  }
  
  Future<void> generateMask(Uint8List imageData, String style) async {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode({
        'action': 'generate_mask',
        'style': style,
        'image': base64Encode(imageData),
      }));
    } else {
      try {
        await http.post(
          Uri.parse('$_baseUrl/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'style': style,
            'image': base64Encode(imageData),
          }),
        );
      } catch (_) {}
    }
  }
  
  Future<void> setStyle(String style) async {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode({
        'action': 'set_style',
        'style': style,
      }));
    }
  }
  
  void dispose() {
    disconnect();
    _frameController.close();
    _statusController.close();
  }
}
