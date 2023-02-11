import 'package:flutter/material.dart';

import 'package:techrace/map.dart';

class HomeTest extends StatefulWidget {
  const HomeTest({super.key});

  @override
  State<HomeTest> createState() => _HomeTestState();
}

class _HomeTestState extends State<HomeTest> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapWidget(),
    );
  }
}
