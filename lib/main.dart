import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:axilerometer_interview_app/src/widgets/app.dart';

void main() {
  FlutterForegroundTask.initCommunicationPort();
  runApp(const App());
}
