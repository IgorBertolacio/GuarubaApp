import 'package:flutter/material.dart';
import 'package:guaruba/presentation/pages/code_page/main_code_page.dart';

class Guaruba extends StatelessWidget {
  const Guaruba({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainCodePage(),
    );
  }
}