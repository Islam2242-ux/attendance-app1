import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFF1E40AF), // Dark Blue
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Custom Wave Shape (Simplified for Flutter)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 90,
            child: CustomPaint(
              painter: BottomNavPainter(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.fingerprint, "Attend"),
              _buildNavItem(1, Icons.history, "History"),
              const SizedBox(width: 40), // Space for center curve
              _buildNavItem(2, Icons.assignment_outlined, "Permit"),
              _buildNavItem(3, Icons.person_outline, "Profile"),
            ],
          ),
          // Center Floating Button Indicator
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7), // Light Green
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1E40AF), width: 8),
                ),
                child: Icon(
                  _getIconForIndex(currentIndex),
                  color: const Color(0xFF16A34A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0: return Icons.fingerprint;
      case 1: return Icons.history;
      case 2: return Icons.assignment_outlined;
      case 3: return Icons.person;
      default: return Icons.home;
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF60A5FA) : Colors.white70,
          size: 28,
        ),
      ),
    );
  }
}

class BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = const Color(0xFF1E40AF);
    Path path = Path();
    
    path.moveTo(0, 20);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20), radius: const Radius.circular(10.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
