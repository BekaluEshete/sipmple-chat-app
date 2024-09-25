import 'package:flutter/material.dart';

class SnapshotScreen extends StatelessWidget {
  const SnapshotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('chat app')),
        ),
        body: const Center(
          child: Text("Loading........."),
        ));
  }
}
