import 'package:axilerometer_interview_app/src/widgets/screens/home_screen.dart';
import 'package:flutter/material.dart';

/// The main entry point of the app.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Interview Demo',
    home: const HomePage(title: 'Flutter Demo Home Page'),
  );
}
