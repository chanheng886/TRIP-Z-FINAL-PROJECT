import 'package:flutter/material.dart';
import 'package:frontend/app/main_app.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainApp(), debugShowCheckedModeBanner: false);
  }
}
