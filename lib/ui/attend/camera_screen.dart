import 'package:attendance_app/ui/attend/attend_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with TickerProviderStateMixin {
  CameraController? controller;
  bool _isCameraInitialized = false;
  late AnimationController _animationController;
  late AnimationController _scannerAnimationController;
  late Animation<double> _scannerAnimation;

  @override
  void initState() {
    onCameraSelected();
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scannerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scannerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scannerAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _scannerAnimationController.repeat();
  }

  void onCameraSelected() async {
    final cameras = await availableCameras();
    // Select front camera by default
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    
    controller = CameraController(frontCamera, ResolutionPreset.medium);
    await controller!.initialize();
    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    controller?.dispose();
    _animationController.dispose();
    _scannerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(controller!),
          ),
          
          // Overlay Scanner Effect with Animation
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 0, 229, 255),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF00E5FF),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Corner accents
                        Positioned(
                          top: 0, left: 0,
                          child: _buildCorner(false, false),
                        ),
                        Positioned(
                          top: 0, right: 0,
                          child: _buildCorner(false, true),
                        ),
                        Positioned(
                          bottom: 0, left: 0,
                          child: _buildCorner(true, false),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: _buildCorner(true, true),
                        ),
                        
                        // Scanner Line Animation
                        AnimatedBuilder(
                          animation: _scannerAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: 140 + (_scannerAnimation.value * 120),
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF00E5FF),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "ALIGN FACE WITHIN FRAME",
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Capture Button with Animation
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  try {
                    final image = await controller!.takePicture();
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => AttendScreen(image: image),
                      ),
                    );
                  } catch (e) {
                    debugPrint("Error taking picture: $e");
                  }
                },
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_animationController.value * 0.1),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool bottom, bool right) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: bottom ? BorderSide.none : const BorderSide(color: Color(0xFF00E5FF), width: 4),
          bottom: bottom ? const BorderSide(color: Color(0xFF00E5FF), width: 4) : BorderSide.none,
          left: right ? BorderSide.none : const BorderSide(color: Color(0xFF00E5FF), width: 4),
          right: right ? const BorderSide(color: Color(0xFF00E5FF), width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}