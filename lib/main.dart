import 'package:flutter/material.dart';
import 'bluetooth_screen.dart';  // Bluetooth 스크린을 임포트

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScanScreen(),  // ReactionSupportScreen을 메인 화면으로 설정
    );
  }
}
