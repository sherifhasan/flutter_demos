import 'package:flutter/material.dart';
import 'package:leak_tracker/leak_tracker.dart';
import 'image_list_screen.dart';

void main() {
  LeakTracking.start(
    config: const LeakTrackingConfig(
      stdoutLeaks: true,
      checkPeriod: Duration(seconds: 2),
      disposalTime: Duration(milliseconds: 500),
      numberOfGcCycles: 2,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image List Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ImageListScreen(),
    );
  }
}
