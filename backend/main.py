"""
AutoARMask Studio - Python Backend
Real-time face processing and virtual camera output
"""

import asyncio
import base64
import json
import cv2
import numpy as np
from io import BytesIO
from PIL import Image
from typing import Optional
import threading
import time

# Try importing optional dependencies
try:
    import mediapipe as mp
    HAS_MEDIAPIPE = True
except ImportError:
    HAS_MEDIAPIPE = False
    print("WARNING: MediaPipe not installed, face mesh features disabled")

try:
    import pyvirtualcam
    HAS_VIRTUALCAM = True
except ImportError:
    HAS_VIRTUALCAM = False
    print("WARNING: pyvirtualcam not installed, virtual camera disabled")

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import uvicorn


# ============= Face Processing Engine =============

class FaceProcessor:
    """Handles face detection, mesh extraction, and style application"""
    
    def __init__(self):
        self.face_mesh = None
        self.face_detection = None
        self.current_style = None
        self.style_image = None
        self.source_image = None
        
        if HAS_MEDIAPIPE:
            self.mp_face_mesh = mp.solutions.face_mesh
            self.mp_face_detection = mp.solutions.face_detection
            self.face_mesh = self.mp_face_mesh.FaceMesh(
                max_num_faces=1,
                refine_landmarks=True,
                min_detection_confidence=0.5,
                min_tracking_confidence=0.5
            )
            self.face_detection = self.mp_face_detection.FaceDetection(
                model_selection=0,
                min_detection_confidence=0.5
            )
    
    def set_style(self, style_name: str, style_image: Optional[np.ndarray] = None):
        """Set the current face style"""
        self.current_style = style_name
        if style_image is not None:
            self.style_image = style_image
    
    def set_source_image(self, image_data: bytes):
        """Set the source face image for swapping"""
        nparr = np.frombuffer(image_data, np.uint8)
        self.source_image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    def process_frame(self, frame: np.ndarray) -> np.ndarray:
        """Process a single frame with face effects"""
        if not HAS_MEDIAPIPE or self.face_mesh is None:
            return frame
        
        # Convert BGR to RGB
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        
        # Process face mesh
        results = self.face_mesh.process(rgb_frame)
        
        if results.multi_face_landmarks:
            for face_landmarks in results.multi_face_landmarks:
                # Apply style effects based on current style
                frame = self._apply_style_overlay(frame, face_landmarks)
        
        return frame
    
    def _apply_style_overlay(self, frame: np.ndarray, landmarks) -> np.ndarray:
        """Apply visual style overlay to the face"""
        h, w = frame.shape[:2]
        
        # Get face bounding box from landmarks
        x_coords = [lm.x * w for lm in landmarks.landmark]
        y_coords = [lm.y * h for lm in landmarks.landmark]
        
        x_min = int(min(x_coords))
        x_max = int(max(x_coords))
        y_min = int(min(y_coords))
        y_max = int(max(y_coords))
        
        # Apply different effects based on style
        if self.current_style == "Qin Shi Huang":
            # Golden emperor overlay effect
            overlay = frame.copy()
            cv2.rectangle(overlay, (x_min, y_min), (x_max, y_max), (0, 215, 255), 2)
            # Add golden tint to face region
            mask = np.zeros_like(frame)
            mask[y_min:y_max, x_min:x_max] = (0, 50, 80)
            frame = cv2.addWeighted(frame, 0.9, mask, 0.1, 0)
            
        elif self.current_style == "Anime":
            # Anime-style edge enhancement
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            edges = cv2.Canny(gray, 100, 200)
            edges_colored = cv2.cvtColor(edges, cv2.COLOR_GRAY2BGR)
            # Smooth skin effect
            face_region = frame[y_min:y_max, x_min:x_max]
            if face_region.size > 0:
                smoothed = cv2.bilateralFilter(face_region, 9, 75, 75)
                frame[y_min:y_max, x_min:x_max] = smoothed
            # Pink tint
            mask = np.zeros_like(frame)
            mask[y_min:y_max, x_min:x_max] = (147, 105, 255)
            frame = cv2.addWeighted(frame, 0.95, mask, 0.05, 0)
            
        elif self.current_style == "Cinematic":
            # Cinematic color grading
            frame = cv2.convertScaleAbs(frame, alpha=1.1, beta=10)
            # Add slight vignette
            rows, cols = frame.shape[:2]
            kernel_x = cv2.getGaussianKernel(cols, cols/2)
            kernel_y = cv2.getGaussianKernel(rows, rows/2)
            kernel = kernel_y * kernel_x.T
            mask = kernel / kernel.max()
            mask = np.stack([mask] * 3, axis=-1)
            frame = (frame * 0.3 + frame * mask * 0.7).astype(np.uint8)
            # Teal and orange look
            frame[:, :, 0] = np.clip(frame[:, :, 0] * 1.1, 0, 255)  # Blue boost
            frame[:, :, 2] = np.clip(frame[:, :, 2] * 1.05, 0, 255)  # Red boost
            
        elif self.current_style == "Realistic":
            # Skin smoothing and enhancement
            face_region = frame[y_min:y_max, x_min:x_max]
            if face_region.size > 0:
                smoothed = cv2.bilateralFilter(face_region, 5, 50, 50)
                sharpened = cv2.addWeighted(face_region, 1.5, smoothed, -0.5, 0)
                frame[y_min:y_max, x_min:x_max] = sharpened
        
        return frame


# ============= Virtual Camera Manager =============

class VirtualCameraManager:
    """Manages the system virtual camera output"""
    
    def __init__(self, width=1280, height=720, fps=30):
        self.width = width
        self.height = height
        self.fps = fps
        self.camera = None
        self.is_running = False
    
    def start(self):
        """Start the virtual camera"""
        if not HAS_VIRTUALCAM:
            print("Virtual camera not available - pyvirtualcam not installed")
            return False
        
        try:
            self.camera = pyvirtualcam.Camera(
                width=self.width,
                height=self.height,
                fps=self.fps,
                device='AutoARMaskCam'
            )
            self.is_running = True
            print(f"Virtual camera started: {self.camera.device}")
            return True
        except Exception as e:
            print(f"Failed to start virtual camera: {e}")
            return False
    
    def send_frame(self, frame: np.ndarray):
        """Send a frame to the virtual camera"""
        if self.camera and self.is_running:
            # Resize if needed
            if frame.shape[:2] != (self.height, self.width):
                frame = cv2.resize(frame, (self.width, self.height))
            # Convert BGR to RGB
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            self.camera.send(frame_rgb)
            self.camera.sleep_until_next_frame()
    
    def stop(self):
        """Stop the virtual camera"""
        if self.camera:
            self.camera.close()
            self.camera = None
        self.is_running = False


# ============= Camera Capture =============

class CameraCapture:
    """Handles webcam capture"""
    
    def __init__(self, device_id=0, width=1280, height=720, fps=30):
        self.device_id = device_id
        self.width = width
        self.height = height
        self.fps = fps
        self.cap = None
        self.is_running = False
        self.last_frame = None
        self._capture_thread = None
    
    def start(self):
        """Start webcam capture"""
        self.cap = cv2.VideoCapture(self.device_id, cv2.CAP_DSHOW)
        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, self.width)
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, self.height)
        self.cap.set(cv2.CAP_PROP_FPS, self.fps)
        
        if not self.cap.isOpened():
            print("Failed to open webcam")
            return False
        
        self.is_running = True
        self._capture_thread = threading.Thread(target=self._capture_loop, daemon=True)
        self._capture_thread.start()
        return True
    
    def _capture_loop(self):
        """Background capture loop"""
        while self.is_running:
            ret, frame = self.cap.read()
            if ret:
                self.last_frame = frame
            time.sleep(1 / self.fps)
    
    def get_frame(self) -> Optional[np.ndarray]:
        """Get the latest frame"""
        return self.last_frame
    
    def stop(self):
        """Stop capture"""
        self.is_running = False
        if self._capture_thread:
            self._capture_thread.join(timeout=1.0)
        if self.cap:
            self.cap.release()


# ============= Main Application =============

class AutoARMaskBackend:
    """Main backend application"""
    
    def __init__(self):
        self.face_processor = FaceProcessor()
        self.virtual_camera = VirtualCameraManager()
        self.camera_capture = CameraCapture()
        
        self.is_camera_active = False
        self.is_processing = False
        self._process_thread = None
        
        self.connected_clients: list[WebSocket] = []
    
    def start_camera(self):
        """Start the camera pipeline"""
        if self.is_camera_active:
            return True
        
        # Start webcam
        if not self.camera_capture.start():
            return False
        
        # Start virtual camera
        self.virtual_camera.start()
        
        # Start processing
        self.is_camera_active = True
        self._process_thread = threading.Thread(target=self._process_loop, daemon=True)
        self._process_thread.start()
        
        return True
    
    def stop_camera(self):
        """Stop the camera pipeline"""
        self.is_camera_active = False
        if self._process_thread:
            self._process_thread.join(timeout=1.0)
        self.camera_capture.stop()
        self.virtual_camera.stop()
    
    def _process_loop(self):
        """Main processing loop"""
        while self.is_camera_active:
            frame = self.camera_capture.get_frame()
            if frame is not None:
                # Process frame
                processed = self.face_processor.process_frame(frame)
                
                # Send to virtual camera
                self.virtual_camera.send_frame(processed)
                
                # Encode for websocket streaming
                _, buffer = cv2.imencode('.jpg', processed, [cv2.IMWRITE_JPEG_QUALITY, 70])
                self._broadcast_frame(buffer.tobytes())
            
            time.sleep(1 / 30)  # 30 FPS
    
    def _broadcast_frame(self, frame_data: bytes):
        """Broadcast frame to connected clients"""
        # This will be called from the processing thread
        for client in self.connected_clients[:]:
            try:
                asyncio.run(client.send_bytes(frame_data))
            except:
                pass
    
    def generate_mask(self, image_data: bytes, style: str):
        """Generate mask from source image"""
        self.face_processor.set_source_image(image_data)
        self.face_processor.set_style(style)
        return True


# ============= FastAPI Server =============

app = FastAPI(title="AutoARMask Studio Backend")
backend = AutoARMaskBackend()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    return {"status": "AutoARMask Studio Backend Running"}


@app.post("/start")
async def start_camera():
    success = backend.start_camera()
    return {"success": success, "message": "Camera started" if success else "Failed to start camera"}


@app.post("/stop")
async def stop_camera():
    backend.stop_camera()
    return {"success": True, "message": "Camera stopped"}


@app.post("/generate")
async def generate_mask(data: dict):
    style = data.get("style", "Realistic")
    image_b64 = data.get("image", "")
    
    if image_b64:
        image_data = base64.b64decode(image_b64)
        backend.generate_mask(image_data, style)
    else:
        backend.face_processor.set_style(style)
    
    return {"success": True, "message": f"Style set to {style}"}


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    backend.connected_clients.append(websocket)
    
    # Send initial status
    await websocket.send_json({
        "camera_active": backend.is_camera_active,
        "obs_connected": backend.virtual_camera.is_running,
        "message": "Connected to AutoARMask Backend"
    })
    
    try:
        while True:
            data = await websocket.receive_text()
            msg = json.loads(data)
            action = msg.get("action")
            
            if action == "start_camera":
                success = backend.start_camera()
                await websocket.send_json({
                    "camera_active": success,
                    "obs_connected": backend.virtual_camera.is_running,
                    "message": "Camera started" if success else "Failed to start"
                })
            
            elif action == "stop_camera":
                backend.stop_camera()
                await websocket.send_json({
                    "camera_active": False,
                    "obs_connected": False,
                    "message": "Camera stopped"
                })
            
            elif action == "generate_mask":
                style = msg.get("style", "Realistic")
                image_b64 = msg.get("image", "")
                if image_b64:
                    image_data = base64.b64decode(image_b64)
                    backend.generate_mask(image_data, style)
                else:
                    backend.face_processor.set_style(style)
                await websocket.send_json({
                    "camera_active": backend.is_camera_active,
                    "message": f"Style set to {style}"
                })
            
            elif action == "set_style":
                style = msg.get("style", "Realistic")
                backend.face_processor.set_style(style)
                await websocket.send_json({
                    "message": f"Style changed to {style}"
                })
    
    except WebSocketDisconnect:
        backend.connected_clients.remove(websocket)


def main():
    print("=" * 50)
    print("  AutoARMask Studio Backend")
    print("=" * 50)
    print(f"MediaPipe: {'Available' if HAS_MEDIAPIPE else 'Not Installed'}")
    print(f"Virtual Camera: {'Available' if HAS_VIRTUALCAM else 'Not Installed'}")
    print("=" * 50)
    print("Starting server on http://localhost:8765")
    print("WebSocket: ws://localhost:8765/ws")
    print("=" * 50)
    
    uvicorn.run(app, host="0.0.0.0", port=8765)


if __name__ == "__main__":
    main()
