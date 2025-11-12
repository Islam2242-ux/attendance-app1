import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'ui/home_screen.dart' show HomeScreen;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // Nilai-nilai diambil dari google-services.json:
        // "api_key": [{"current_key": "AIzaSyCQVlYrMTMbfZfUrRQ9XAAjvT-awHQjFpM"}]
        apiKey: 'AIzaSyCQVlYrMTMbfZfUrRQ9XAAjvT-awHQjFpM', // api_key
        
        // "client": [{"client_info": {"mobilesdk_app_id": "1:662893120037:android:a5873a26e408c3368b4dcc"}}]
        appId:
            '1:662893120037:android:a5873a26e408c3368b4dcc', // mobilesdk_app_id
        
        // "project_info": {"project_number": "662893120037"}
        messagingSenderId: '662893120037', // project_number
        
        // "project_info": {"project_id": "attendance-app-edb62"}
        projectId: 'attendance-app-edb62', // project_id
        
        // Opsional: Anda mungkin ingin menambahkan storageBucket juga
        // "project_info": {"storage_bucket": "attendance-app-edb62.firebasestorage.app"}
        storageBucket: 'attendance-app-edb62.firebasestorage.app', 
      ),
    );
    // Koneksi Firebase berhasil
    print("KAU Terhubung dengan Firebase:");
    print("API Key KAU: ${Firebase.app().options.apiKey}");
    print("Project ID KAU: ${Firebase.app().options.projectId}");
  } catch (e) {
    // Koneksi Firebase gagal
    print("Firebase gagal terhubung: $e");
  }
  // runApp(const HomeScreen());
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  // Main App
  const TestApp({super.key}); // Constructor of TestApp clas

  @override // can give information about about your missing override code
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // remove debug banner
      home: const HomeScreen(), // HomeScreen class
    );
  }
}
