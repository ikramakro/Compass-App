import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasPermission = false;
  @override
  void initState() {
    super.initState();
    fetchPermissionStatus();
  }

  void fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        hasPermission = (status == PermissionStatus.granted);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              if (hasPermission) {
                return buildCompass();
              } else {
                return buildPermissionStatus();
              }
            },
          ),
        ));
  }

  Widget buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        double? direction = snapshot.data!.heading;

        if (direction == null) {
          return const Center(child: Text('Device not support sensor'));
        }
        return Center(
            child: Transform.rotate(
          angle: direction * (math.pi / 180) * -1,
          child: AnimatedContainer(
            duration: const Duration(seconds: 1),
            child: Image.asset(
              'assets/compass.png',
            ),
          ),
        ));
      },
    );
  }

  Widget buildPermissionStatus() {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            Permission.locationWhenInUse.request().then((value) {
              fetchPermissionStatus();
            });
          },
          child: const Text('Request Permission ')),
    );
  }
}
