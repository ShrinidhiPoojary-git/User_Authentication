import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/Theme/theme.dart';
import 'package:flutter_application/dashboard_page.dart';
import 'package:flutter_application/login_page.dart';
import 'package:flutter_application/signup_page.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(options: const FirebaseOptions(
      apiKey: "AIzaSyCHv1RTYoHc__DUCTYISG0BrD0mBLSf064", 
      appId: "1:406470294847:web:9a2edbbe2498bde474a78a", 
      messagingSenderId: "406470294847", 
      projectId: "flutter-firebase-d43ab"));
  }
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SignUp Page',
      theme: AppTheme.darkThemeMode,
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signUp': (context) => const SignUpPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}
