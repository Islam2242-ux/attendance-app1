import 'package:attendance_app/ui/absent/absent_screen.dart';
import 'package:attendance_app/ui/attend/attend_screen.dart';
import 'package:attendance_app/ui/attendance_history/attendance_history_screen.dart';
import 'package:attendance_app/ui/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<Widget> _screens = [
    const AttendScreen(),
    const AttendanceHistoryScreen(),
    const AbsentScreen(),
    const Center(child: Text("Profile Screen")),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Warna background abu sangat muda (bersih)
      body: Column(
        children: [
          // --- BAR 1: ADMIN USER (HEADER) ---
          // Ini adalah bar paling atas yang terpisah
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10, // Padding status bar
              bottom: 25, // Padding bawah agar agak luas
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB), // Warna Biru Utama
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFF2563EB), size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Welcome Back",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        "Admin User",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // --- KONTEN SCROLLABLE DI BAWAH HEADER ---
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // --- BAR 2: BANNER "HOW ARE YOU" ---
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        // GARIS TEPIAN HANYA PADA BAWAH (Border Bottom)
                        border: const Border(
                          bottom: BorderSide(
                            color: Color(0xFF2563EB), // Warna biru sama dengan header
                            width: 6.0, // Ketebalan garis
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Animated chart illustration
                          const SizedBox(
                            height: 70,
                            width: 90,
                            child: AnimatedChart(),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "How Are You",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800, // Lebih tebal
                                    color: Color(0xFF1E293B),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Make your day productive",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- TAB SELECTOR (PILL SHAPE) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E40AF), // Dark Blue Pill
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E40AF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon kecil di sebelah teks tab untuk mempermanis
                              Icon(
                                _currentIndex == 0 ? Icons.check_circle :
                                _currentIndex == 1 ? Icons.history :
                                _currentIndex == 2 ? Icons.edit_document : Icons.person,
                                color: Colors.white, 
                                size: 18
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _currentIndex == 0 ? "Check In" : 
                                _currentIndex == 1 ? "History" :
                                _currentIndex == 2 ? "Permission" : "Profile",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- DYNAMIC CONTENT AREA (Isi Halaman) ---
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.fastOutSlowIn,
                    switchOutCurve: Curves.fastOutSlowIn,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.05), // Muncul sedikit dari bawah
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey<int>(_currentIndex),
                      // Kita hapus fixed height container agar mengikuti konten (Expanded di parent akan handle, 
                      // tapi karena ini dalam ScrollView, kita biarkan ukurannya menyesuaikan konten anak)
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.5, // Minimal setengah layar
                      ),
                      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 24),
                      child: _screens[_currentIndex],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Animated Chart Widget (Grafik Batang di Banner)
class AnimatedChart extends StatefulWidget {
  const AnimatedChart({super.key});

  @override
  State<AnimatedChart> createState() => _AnimatedChartState();
}

class _AnimatedChartState extends State<AnimatedChart> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            0.6 + index * 0.1,
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBar(height: 25, color: Colors.lightBlue[100]!, anim: _animations[0]),
        _buildBar(height: 55, color: Colors.lightBlue[300]!, anim: _animations[1]), // Bar tertinggi ke-2
        _buildBar(height: 35, color: Colors.lightBlue[200]!, anim: _animations[2]),
        _buildBar(height: 65, color: const Color(0xFF2563EB), anim: _animations[3]), // Bar paling tinggi (Biru Tua)
      ],
    );
  }

  Widget _buildBar({required double height, required Color color, required Animation<double> anim}) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return Container(
          width: 12,
          height: height * anim.value,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        );
      },
    );
  }
}