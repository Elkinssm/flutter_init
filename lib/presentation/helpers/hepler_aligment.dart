import 'package:coach_app/presentation/screens/test_screen.dart';
import 'package:flutter/material.dart';

class HeplerAligment extends StatefulWidget {
  const HeplerAligment({super.key});

  @override
  State<HeplerAligment> createState() => _HeplerAligmentState();
}

class _HeplerAligmentState extends State<HeplerAligment> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(children: [AlignmentTab()]));
  }
}
