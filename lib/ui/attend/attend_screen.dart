import 'dart:io';
import 'package:attendance_app/ui/attend/camera_screen.dart';
import 'package:attendance_app/ui/home_screen.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class AttendScreen extends StatefulWidget {
  final XFile? image;

  const AttendScreen({super.key, this.image});

  @override
  State<AttendScreen> createState() => _AttendScreenState();
}

class _AttendScreenState extends State<AttendScreen> with TickerProviderStateMixin {
  XFile? image;
  String strAddress = "Locating...",
      strDate = "",
      strTime = "",
      strDateTime = "",
      strStatus = "Attend";
  bool isLoading = false;
  double dLat = 0.0, dLong = 0.0;
  int dateHours = 0, dateMinutes = 0;
  final controllerName = TextEditingController();
  final CollectionReference dataCollection =
      FirebaseFirestore.instance.collection('attendance');
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    image = widget.image;
    handleLocationPermission();
    setDateTime();
    setStatusAbsen();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));

    if (image != null) {
      isLoading = true;
      getGeoLocationPosition();
    }

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Clock Card with Animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (1 - _animationController.value) * 50),
                child: Opacity(
                  opacity: _animationController.value,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 41, 120, 246), // Google Blue style
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4285F4).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              strDate,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(strStatus),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            strStatus.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 30),

          // Camera Icon Placeholder with Animation
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CameraScreen()));
            },
            child: image != null
              ? Hero(
                  tag: 'camera_image',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(image!.path), height: 150, width: 200, fit: BoxFit.cover),
                  ),
                )
              : AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 80,
                            color: const Color.fromARGB(255, 41, 120, 246),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "TAP TO SCAN FACE",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 41, 120, 246),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),

          const SizedBox(height: 40),

          // Location Field with Animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset((1 - _animationController.value) * -50, 0),
                child: Opacity(
                  opacity: _animationController.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        icon: Icon(Icons.location_on_outlined, color: Colors.blue[700]),
                        hintText: strAddress,
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Name Field with Animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset((1 - _animationController.value) * 50, 0),
                child: Opacity(
                  opacity: _animationController.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: controllerName,
                      decoration: InputDecoration(
                        icon: Icon(Icons.person_outline, color: Colors.blue[700]),
                        hintText: "Enter your full name",
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // Confirm Button with Animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (1 - _animationController.value) * 50),
                child: Opacity(
                  opacity: _animationController.value,
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (image == null || controllerName.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please complete all fields")),
                          );
                        } else {
                          submitAbsen(strAddress, controllerName.text, strStatus);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                      ),
                      child: const Text(
                        "CONFIRM ATTENDANCE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'attend':
        return Colors.green.withOpacity(0.2);
      case 'late':
        return Colors.orange.withOpacity(0.2);
      case 'leave':
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.white.withOpacity(0.2);
    }
  }
  
  Future<void> getGeoLocationPosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    setState(() { isLoading = false; getAddressFromLongLat(position); });
  }

  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
      dLat = position.latitude;
      dLong = position.longitude;
      strAddress = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
    });
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  void setDateTime() {
    var dateNow = DateTime.now();
    var dateFormat = DateFormat('dd MMMM yyyy');
    var dateTime = DateFormat('HH:mm:ss');
    var dateHour = DateFormat('HH');
    var dateMinute = DateFormat('mm');

    setState(() {
      strDate = dateFormat.format(dateNow);
      strTime = dateTime.format(dateNow);
      strDateTime = "$strDate | $strTime";
      dateHours = int.parse(dateHour.format(dateNow));
      dateMinutes = int.parse(dateMinute.format(dateNow));
    });
  }

  void setStatusAbsen() {
    if (dateHours < 8 || (dateHours == 8 && dateMinutes <= 30)) {
      strStatus = "Attend";
    } else if ((dateHours > 8 && dateHours < 18) || (dateHours == 8 && dateMinutes >= 31)) {
      strStatus = "Late";
    } else {
      strStatus = "Leave";
    }
  }

  Future<void> submitAbsen(String alamat, String nama, String status) async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await dataCollection.add({'address': alamat, 'name': nama, 'description': status, 'datetime': strDateTime});
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Attendance Recorded Successfully!"), backgroundColor: Colors.green));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}