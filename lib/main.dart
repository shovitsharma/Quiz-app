import 'package:flutter/material.dart';
import 'package:quiz_app/client/pages/thankyou_page.dart';
import 'package:quiz_app/first_page.dart';

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
