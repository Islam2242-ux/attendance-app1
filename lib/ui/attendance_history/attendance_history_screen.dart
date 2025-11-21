import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final int _itemsPerPage = 3;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;
        
        if (docs.isEmpty) {
          return _buildEmptyState();
        }

        // 1. Parse Data & Ambil Doc ID untuk Delete
        List<Map<String, dynamic>> allData = docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // PENTING: Simpan ID dokumen agar bisa dihapus nanti
          data['doc_id'] = doc.id; 
          return _parseData(data);
        }).toList();

        // 2. Sorting (Terbaru di atas)
        allData.sort((a, b) => b['raw_date'].compareTo(a['raw_date']));

        // 3. Logika Pagination
        final int totalPages = (allData.length / _itemsPerPage).ceil();
        
        if (_currentPage >= totalPages && totalPages > 0) {
          _currentPage = totalPages - 1;
        } else if (totalPages == 0) {
          _currentPage = 0;
        }

        final int startIndex = _currentPage * _itemsPerPage;
        final int endIndex = min(startIndex + _itemsPerPage, allData.length);
        final List<Map<String, dynamic>> currentData = allData.sublist(startIndex, endIndex);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Attendance History",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Swipe left to delete item", // Petunjuk penggunaan
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // --- LISTVIEW ---
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: currentData.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final data = currentData[index];
                  
                  // --- FITUR DELETE (DISMISSIBLE) ---
                  return Dismissible(
                    key: Key(data['doc_id']), // Key unik dari ID Firestore
                    direction: DismissDirection.endToStart, // Geser Kanan ke Kiri
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 30),
                    ),
                    // Dialog Konfirmasi sebelum hapus
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text("Are you sure you want to delete this history?"),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    // Aksi Hapus ke Firebase
                    onDismissed: (direction) {
                      FirebaseFirestore.instance
                          .collection('attendance')
                          .doc(data['doc_id'])
                          .delete();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("Attendance deleted"), duration: Duration(seconds: 1)),
                      );
                    },
                    // Animasi Masuk
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey("${_currentPage}_${data['raw_date']}"),
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + (index * 150)),
                      curve: Curves.fastOutSlowIn,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 40 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildHistoryCard(data),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // --- PAGINATION ---
              if (totalPages > 1)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        isActive: _currentPage > 0,
                        onTap: () => setState(() => _currentPage--),
                      ),
                      
                      Text(
                        "Page ${_currentPage + 1} of $totalPages",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),

                      _buildNavButton(
                        icon: Icons.arrow_forward_ios_rounded,
                        isActive: _currentPage < totalPages - 1,
                        onTap: () => setState(() => _currentPage++),
                      ),
                    ],
                  ),
                ),
                
               const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _parseData(Map<String, dynamic> data) {
    String rawDatetime = data['datetime'] ?? '';
    String description = data['description'] ?? 'Unknown';
    
    String date = '';
    String time = '';
    String type = ''; 

    if (rawDatetime.contains('|')) {
      List<String> split = rawDatetime.split('|');
      date = split[0].trim();
      time = split.length > 1 ? split[1].trim() : '-';
    } else if (rawDatetime.contains('-')) {
      date = rawDatetime;
      time = "Full Day";
    } else {
      date = rawDatetime;
      time = "-";
    }

    if (description.toLowerCase().contains('attend')) {
      type = 'On Time';
    } else if (description.toLowerCase().contains('late')) {
      type = 'Late In';
    } else if (description.toLowerCase().contains('leave') || description.toLowerCase().contains('sick')) {
      type = 'Permit';
    } else {
      type = 'Activity';
    }

    return {
      'doc_id': data['doc_id'], // Pastikan ID dibawa
      'date': date,
      'time': time,
      'status': description,
      'type': type,
      'raw_date': rawDatetime, 
    };
  }

  Widget _buildHistoryCard(Map<String, dynamic> data) {
    String status = data['status'];
    bool isCheckIn = status.toLowerCase() == 'attend';
    bool isAbsent = status.toLowerCase().contains('sick') || status.toLowerCase().contains('leave');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: isCheckIn 
                    ? const Color(0xFFDCFCE7) 
                    : isAbsent ? const Color(0xFFFEE2E2) : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCheckIn ? Icons.check_circle_outline : isAbsent ? Icons.sick_outlined : Icons.timer_outlined,
                color: isCheckIn 
                    ? const Color(0xFF16A34A) 
                    : isAbsent ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['date'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data['time'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCheckIn ? const Color(0xFF16A34A) : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data['type'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive ? [
             BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey[400],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text("No Data Found", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}