import 'package:attendance_app/ui/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AbsentScreen extends StatefulWidget {
  const AbsentScreen({super.key});

  @override
  State<AbsentScreen> createState() => _AbsentScreenState();
}

class _AbsentScreenState extends State<AbsentScreen> with TickerProviderStateMixin {
  String? _selectedReason;
  final controllerName = TextEditingController();
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('attendance');
  late AnimationController _animationController;
  late List<AnimationController> _fieldControllers;
  late List<Animation<double>> _fieldAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fieldControllers = List.generate(4, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
    });
    
    _fieldAnimations = _fieldControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      );
    }).toList();
    
    _animationController.forward();
    
    // Stagger the field animations
    for (int i = 0; i < _fieldControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 * i), () {
        if (mounted) {
          _fieldControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _fieldControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request Form Title with Animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (1 - _animationController.value) * 30),
                child: Opacity(
                  opacity: _animationController.value,
                  child: const Text(
                    "Request Form",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Name Input with Animation
          _buildAnimatedField(
            index: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Full Name", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: controllerName,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person_outline, color: Colors.blue),
                      hintText: "Enter your full name",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Reason Dropdown with Animation
          _buildAnimatedField(
            index: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Reason", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedReason,
                      hint: const Text("Please Choose:"),
                      isExpanded: true,
                      items: ["Sick", "Permission", "Others"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedReason = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Date Pickers Row with Animation
          _buildAnimatedField(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("From", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context, fromController),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                fromController.text.isEmpty ? "Select Date" : fromController.text,
                                style: TextStyle(
                                  color: fromController.text.isNotEmpty ? Colors.black : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Until", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context, toController),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                toController.text.isEmpty ? "Select Date" : toController.text,
                                style: TextStyle(
                                  color: toController.text.isNotEmpty ? Colors.black : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Submit Button with Animation
          _buildAnimatedField(
            index: 3,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (controllerName.text.isEmpty || _selectedReason == null || fromController.text.isEmpty || toController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
                  } else {
                    submitAbsen(controllerName.text, _selectedReason!, fromController.text, toController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Submit Request",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedField({required int index, required Widget child}) {
    return AnimatedBuilder(
      animation: _fieldAnimations[index],
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, (1 - _fieldAnimations[index].value) * 20),
          child: Opacity(
            opacity: _fieldAnimations[index].value,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> submitAbsen(String nama, String keterangan, String from, String until) async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await dataCollection.add({
        'address': '-',
        'name': nama,
        'description': keterangan,
        'datetime': '$from - $until',
        'created_at': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permission Request Submitted!"), backgroundColor: Colors.green));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}