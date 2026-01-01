import 'dart:async';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart' as ll;

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  final Location _location = Location();

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // Called when service starts
    // You can initialize resources here if needed
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    try {
      final locData = await _location.getLocation();
      if (locData.latitude == null || locData.longitude == null) return;

      final point = ll.LatLng(locData.latitude!, locData.longitude!);

      // Send location to main isolate
      sendPort?.send({
        'lat': point.latitude,
        'lng': point.longitude,
        'time': timestamp.toIso8601String(),
      });
    } catch (e) {
      // ignore errors
    }
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    // Clean up resources if needed
  }

  @override
  void onButtonPressed(String id) {
    // Optional: handle notification button press
  }

  @override
  void onNotificationPressed() {
    // Optional: handle notification tap
  }
}
