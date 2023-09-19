import 'package:flutter/material.dart';
import 'package:zebra_rfid_sdk_plugin_example/rfid_reader_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      home: const RfidReaderScreen(),
    );
  }
}
