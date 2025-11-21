import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  double _getNotchPosition(int index) {
    return (index * 0.25) + 0.125;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    double targetPos = _getNotchPosition(currentIndex);

    return SizedBox(
      height: 90,
      child: Stack(
        children: [
          // 1. Animated Background Curve (Lengkungan)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: targetPos),
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              builder: (context, animatedPos, child) {
                return CustomPaint(
                  size: Size(width, 70),
                  painter: BNBCustomPainter(notchPosition: animatedPos),
                );
              },
            ),
          ),

          // 2. Bottom Navigation Items
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 70,
            child: Row(
              children: [
                Expanded(child: _buildNavItem(0, Icons.fingerprint, "Attend")),
                Expanded(child: _buildNavItem(1, Icons.history, "History")),
                Expanded(child: _buildNavItem(2, Icons.assignment_outlined, "Permit")),
                Expanded(child: _buildNavItem(3, Icons.person_outline, "Profile")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: isSelected ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
        builder: (context, t, child) {
          final double dynamicOffset = -20.0 * t;
          final double shadowOpacity = 0.15 * t;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, dynamicOffset),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.lerp(Colors.transparent, Colors.white, t),
                    shape: BoxShape.circle,
                    boxShadow: [
                       BoxShadow(
                        color: Colors.black.withOpacity(shadowOpacity),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 5)
                      )
                    ]
                  ),
                  child: Icon(
                    icon,
                    color: Color.lerp(Colors.white.withOpacity(0.7), const Color(0xFF1E40AF), t),
                    size: 26,
                  ),
                ),
              ),
              
              if (t < 0.5)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Opacity(
                    opacity: (1.0 - t * 2).clamp(0.0, 1.0),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 17),
            ],
          );
        },
      ),
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  final double notchPosition;

  BNBCustomPainter({required this.notchPosition});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF1E40AF) // Warna Utama (Dark Blue)
      ..style = PaintingStyle.fill;

    // ----- Definisi Path Utama (Lekukan) -----
    Path path = Path();
    double loc = size.width * notchPosition;
    double notchWidth = 70;  
    double notchDepth = 45;  
    double smoothFactor = 55; 

    path.moveTo(0, 0);
    path.lineTo(loc - notchWidth, 0);
    path.cubicTo(
      loc - notchWidth + smoothFactor, 0,        
      loc - notchWidth * 0.6, notchDepth * 0.8,  
      loc, notchDepth,                           
    );
    path.cubicTo(
      loc + notchWidth * 0.6, notchDepth * 0.8,  
      loc + notchWidth - smoothFactor, 0,        
      loc + notchWidth, 0                        
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // ----- MENGGAMBAR BAYANGAN -----

    // 1. Bayangan Tebal di Bawah (memberi kesan melayang)
    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 10.0, true);

    // 2. Bayangan Garis Pinggir di Sekitar Lekukan
    // Untuk ini, kita bisa menggambar path yang sama dengan warna sedikit lebih gelap
    // dan blur radius yang lebih kecil, tepat sebelum path utama.
    // Atau, kita bisa membuat outline path yang terpisah.
    // Metode ini akan menggambar shadow yang lebih fokus di tepi.
    canvas.drawShadow(path, Colors.black.withOpacity(0.4), 3.0, true); // Bayangan lebih gelap dan fokus di tepi

    // ----- MENGGAMBAR PATH UTAMA -----
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BNBCustomPainter oldDelegate) {
    return oldDelegate.notchPosition != notchPosition; 
  }
}