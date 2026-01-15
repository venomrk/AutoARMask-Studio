# AutoARMask Studio

Production-grade AR Virtual Camera Desktop Application with Neural Face Reenactment.

![UI Demo](https://github.com/venomrk/AutoARMask-Studio/blob/master/media/ui-demo.jpg)

## 🎯 Features

- 🎨 **Premium Gaming UI** - Flutter desktop app with dark theme and glowing red accents
- 🤖 **Neural Face Reenactment** - Deep-Live-Cam integration for realistic face swapping
- 📹 **Virtual Camera Output** - Creates "AutoARMaskCam" visible in OBS, Zoom, Teams
- 🎭 **4 Face Styles** - Qin Shi Huang, Anime, Cinematic, Realistic
- ⚡ **Real-time Processing** - 30-60 FPS with MediaPipe face tracking

## 🚀 Quick Start

### Prerequisites
- Windows 10/11 x64
- NVIDIA GPU (RTX 3060 or higher recommended)
- Python 3.11
- Flutter 3.38+

### Installation

1. **Clone the repository**
```powershell
git clone https://github.com/venomrk/AutoARMask-Studio.git
cd AutoARMask-Studio
```

2. **Install Python dependencies**
```powershell
pip install -r backend/requirements.txt
pip install -r Deep-Live-Cam/requirements.txt
```

3. **Download Deep-Live-Cam models**
```powershell
cd Deep-Live-Cam
# Models will be auto-downloaded on first run
```

4. **Install Flutter dependencies**
```powershell
cd flutter_app
flutter pub get
```

### Running the Application

**Option 1: One-Click Start**
```powershell
./start_app.bat
```

**Option 2: Manual Start**
```powershell
# Terminal 1 - Backend
./start_backend.bat

# Terminal 2 - UI
./start_ui.bat
```

## 📋 Current Status

### ✅ Working
- Flutter UI with all panels and controls
- Python FastAPI backend with WebSocket
- MediaPipe face detection and tracking
- Style selector (4 styles)
- Camera capture and preview
- Real-time frame streaming

### ⚠️ In Progress
- **Deep-Live-Cam Integration** - Currently installing dependencies
- **Face Swapping** - Uses MediaPipe overlays, Deep-Live-Cam models needed
- **Virtual Camera** - Requires OBS Virtual Cam plugin

### 🔧 Missing Dependencies

1. **Visual Studio C++ Build Tools** (For Windows native .exe)
   - Download: https://visualstudio.microsoft.com/visual-cpp-build-tools/
   - Install "Desktop development with C++" workload

2. **OBS Studio** (For virtual camera output)
   - Download: https://obsproject.com/
   - Virtual camera included in OBS 26.0+

3. **FFmpeg** (For Deep-Live-Cam video processing)
   - Download: https://ffmpeg.org/download.html
   - Add to PATH

## 🛠️ Technology Stack

- **Frontend**: Flutter 3.38 (Web/Desktop)
- **Backend**: Python 3.11 + FastAPI + uvicorn
- **ML/AI**: Deep-Live-Cam, MediaPipe, InsightFace, ONNX Runtime
- **Face Swap**: Deep-Live-Cam (neural face reenactment)
- **Virtual Camera**: pyvirtualcam + OBS Virtual Cam
- **Communication**: WebSocket (real-time frame streaming)

## 📁 Project Structure

```
AutoARMask Studio/
├── flutter_app/          # Flutter desktop UI
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/     # Home screen
│   │   ├── widgets/     # Glowing panels, style selector, preview
│   │   └── services/    # Backend WebSocket client
│   └── build/web/       # Web build output
├── backend/             # Python ML backend
│   ├── main.py          # FastAPI server with face processing
│   └── requirements.txt
├── Deep-Live-Cam/       # Neural face swap engine
│   ├── modules/
│   └── models/
├── assets/styles/       # Face style templates
├── start_backend.bat
├── start_ui.bat
└── start_app.bat
```

## 🎮 Usage

1. **Start the Application** - Run `start_app.bat`
2. **Upload Photo** - Click the placeholder to upload your face image
3. **Select Style** - Choose from Qin Shi Huang, Anime, Cinematic, or Realistic
4. **Generate Mask** - Click the red "GENERATE MASK" button
5. **Start Camera** - Click "Start Camera" to begin live processing
6. **Use in OBS** - Add "AutoARMaskCam" as a video source

## 🐛 Troubleshooting

### Backend not starting
- Check if port 8765 is available
- Verify Python dependencies: `pip list | grep mediapipe`

### Virtual camera not visible
- Install OBS Studio (includes virtual camera driver)
- Restart OBS after backend starts

### Face swapping not working
- Ensure Deep-Live-Cam models are downloaded
- Check GPU is detected: `nvidia-smi`
- Verify CUDA version matches PyTorch build

## 📝 License

GPL-3.0 License - See LICENSE file

## 🙏 Credits

- [Deep-Live-Cam](https://github.com/hacksider/Deep-Live-Cam) - Face swapping engine
- [MediaPipe](https://mediapipe.dev/) - Face mesh tracking
- [Flutter](https://flutter.dev/) - UI framework

---

⭐ **Star this repo if you find it useful!**
