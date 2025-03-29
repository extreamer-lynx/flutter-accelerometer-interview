import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sensors_plus/sensors_plus.dart';

/// A simple Flutter app that logs accelerometer data to a CSV file
/// and displays it in a list view.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// The accelerometer event stream subscription.
  late final StreamSubscription<AccelerometerEvent> _subscription;

  ///  The flag to indicate whether the service is paused.
  bool _isPaused = false;

  /// The accelerometer data string.
  String _accelData = "";

  /// The logs string.
  String _logs = "";

  /// The log file.
  File? _logFile;

  @override
  void initState() {
    super.initState();
    FlutterForegroundTask.startService(
      notificationTitle: 'Accelerometer Logging',
      notificationText: 'Recording motion data...',
    );
    startLogging();
  }

  /// Starts logging accelerometer data to a CSV file.
  Future<void> startLogging() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/accelerometer_log.csv';
    _logFile = File(filePath);

    if (!await _logFile!.exists()) {
      await _logFile!.writeAsString('timestamp,x,y,z\n', mode: FileMode.write);
    }

    _subscription = accelerometerEventStream().listen((event) async {
      final timestamp = DateTime.now().toIso8601String();
      final line = '$timestamp,${event.x},${event.y},${event.z}\n';
      await _logFile!.writeAsString(line, mode: FileMode.append);
      setState(() {
        _accelData = 'Accelerometer: ${event.x}, ${event.y}, ${event.z}';
      });
    });
  }

  /// Parses the log file and returns a list of strings.
  List<String> get _parseLogFile {
    if (_logs.isEmpty) {
      return [];
    }
    return _logs.split('\n');
  }

  /// Starts or resumes the foreground service.
  Future<void> _startService() async {
    if (_isPaused) {
      _subscription.resume();
      setState(() => _isPaused = false);
    } else {
      _subscription.pause();
      setState(() => _isPaused = true);
    }
  }

  /// Reads the log file and updates the logs string.
  Future<void> _readLogs() async {
    final file = File(_logFile?.path ?? '');
    if (await file.exists()) {
      final content = await file.readAsString();
      setState(() => _logs = content);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Accelerometer Logger')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Accelerometer Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_accelData, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startService,
                child: Text(
                  "${_isPaused ? "Resume" : "Start"} Foreground Service",
                ),
              ),
              ElevatedButton(onPressed: _readLogs, child: Text('Read Logs')),
              ElevatedButton(
                onPressed: () async {
                  setState(() => _logs = "");

                  if (_logFile != null && await _logFile!.exists()) {
                    await _logFile!.delete();
                  }
                },
                child: Text('Delete Logs'),
              ),

              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child:
                    _logs.isEmpty
                        ? Text("No logs yet.")
                        : ListView.builder(
                          itemCount: _parseLogFile.length - 1,
                          itemBuilder: (BuildContext context, int index) {
                            final log = _parseLogFile[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey,
                                    width: 0.5,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade500,
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              alignment: Alignment.centerLeft,
                              child: Text(log),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
