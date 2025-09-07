import 'package:flutter/material.dart';
import 'package:quiz_app/first_page.dart';
import 'package:quiz_app/login.dart';
import 'package:quiz_app/package.flutter/preview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuizFirstPage(),

    );
  }
}
