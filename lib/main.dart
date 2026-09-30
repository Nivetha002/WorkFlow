import 'package:flutter/material.dart';

void main() {
  runApp(const WorkFlowApp());
}

class WorkFlowApp extends StatelessWidget {
  const WorkFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkFlow',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WorkFlow'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Offline-first task management app',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 12),
              Text('Coming soon'),
            ],
          ),
        ),
      ),
    );
  }
}