import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> with TickerProviderStateMixin {
  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('attendance');
  final int _itemsPerPage = 10;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  
  // PERBAIKAN: Mengubah tipe dari DocumentSnapshot menjadi QueryDocumentSnapshot
  List<QueryDocumentSnapshot> _allDocuments = [];
  List<QueryDocumentSnapshot> _displayedDocuments = [];
  
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _fetchData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    
    QuerySnapshot querySnapshot = await dataCollection.orderBy('created_at', descending: true).get();
    _allDocuments = querySnapshot.docs;
    _totalItems = _allDocuments.length;
    _totalPages = (_totalItems / _itemsPerPage).ceil();
    _currentPage = 1;
    _updateDisplayedDocuments();
    
    setState(() {
      _isLoading = false;
    });
    
    _animationController.reset();
    _animationController.forward();
  }

  void _updateDisplayedDocuments() {
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    
    if (endIndex > _allDocuments.length) {
      endIndex = _allDocuments.length;
    }
    
    setState(() {
      _displayedDocuments = _allDocuments.sublist(startIndex, endIndex);
    });
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      setState(() {
        _currentPage = page;
        _updateDisplayedDocuments();
      });
      
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search attendance records...",
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Implement search functionality here
              },
            ),
          ),
        ),
        
        // History List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _displayedDocuments.isNotEmpty
                  ? FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _displayedDocuments.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildAnimatedHistoryCard(_displayedDocuments[index], index);
                        },
                      ),
                    )
                  : const Center(child: Text("No records found", style: TextStyle(color: Colors.grey))),
        ),
        
        // Pagination Controls
        if (_totalPages > 1)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous Button
                IconButton(
                  onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
                  icon: const Icon(Icons.chevron_left),
                  color: _currentPage > 1 ? Colors.blue : Colors.grey,
                ),
                
                // Page Numbers
                ...List.generate(
                  _totalPages > 5 ? 5 : _totalPages,
                  (index) {
                    int pageNum;
                    if (_totalPages <= 5) {
                      pageNum = index + 1;
                    } else if (_currentPage <= 3) {
                      pageNum = index + 1;
                    } else if (_currentPage >= _totalPages - 2) {
                      pageNum = _totalPages - 4 + index;
                    } else {
                      pageNum = _currentPage - 2 + index;
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => _goToPage(pageNum),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _currentPage == pageNum ? Colors.blue : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _currentPage == pageNum ? Colors.blue : Colors.grey,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              pageNum.toString(),
                              style: TextStyle(
                                color: _currentPage == pageNum ? Colors.white : Colors.black,
                                fontWeight: _currentPage == pageNum ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Dots indicator if there are more pages
                if (_totalPages > 5)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text("..."),
                  ),
                
                // Next Button
                IconButton(
                  onPressed: _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
                  icon: const Icon(Icons.chevron_right),
                  color: _currentPage < _totalPages ? Colors.blue : Colors.grey,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAnimatedHistoryCard(QueryDocumentSnapshot doc, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, 0, 0),
      child: _buildHistoryCard(doc),
    );
  }

  Widget _buildHistoryCard(QueryDocumentSnapshot doc) {
    var name = doc['name'];
    var description = doc['description'];
    var datetime = doc['datetime'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar Circle with Animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.toString().isNotEmpty ? name[0].toString().toUpperCase() : "?",
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  datetime,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Status & Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(description),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  description,
                  style: TextStyle(
                    color: _getStatusTextColor(description),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _deleteData(doc.id),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'attend':
        return Colors.green[100]!;
      case 'late':
        return Colors.orange[100]!;
      case 'leave':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'attend':
        return Colors.green[800]!;
      case 'late':
        return Colors.orange[800]!;
      case 'leave':
        return Colors.red[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  void _deleteData(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog first
              await dataCollection.doc(docId).delete();
              _fetchData(); // Refresh data after deletion
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}