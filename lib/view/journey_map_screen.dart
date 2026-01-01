// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map/flutter_map.dart' as ll;
// import 'package:latlong2/latlong.dart' as ll;
//
// import '../model/journey_model.dart';
//
//
// class JourneyMapScreen extends StatelessWidget {
//   final Journey journey;
//   final ll.LatLng? startLocation;
//   final ll.LatLng? endLocation;
//
//   JourneyMapScreen({
//     super.key,
//     required this.journey,
//     this.startLocation,
//     this.endLocation,
//   });
//
//   // Map controller
//   final MapController _mapController = MapController();
//
//   // Fallback center (Dhaka)
//   final ll.LatLng _fallbackCenter = const ll.LatLng(23.780573, 90.279239);
//
//   ll.LatLng get _mapCenter => startLocation ?? _fallbackCenter;
//
//   void _handleMapTap(ll.TapPosition _, ll.LatLng tappedPoint) {
//     // Intentionally empty – we don't want to change start/end by tap.
//   }
//
//   List<Marker> _buildMapMarkers(Journey? journey) {
//     final markers = <Marker>[];
//
//     // 1) START marker (use passed startLocation if available)
//     if (startLocation != null) {
//       markers.add(
//         Marker(
//           point: startLocation!,
//           width: 50,
//           height: 50,
//           alignment: Alignment.topCenter,
//           child: const Icon(
//             Icons.flag,
//             size: 36,
//             color: Colors.indigo,
//           ),
//         ),
//       );
//     }
//
//     // 2) END marker (use passed endLocation if available)
//     if (endLocation != null) {
//       markers.add(
//         Marker(
//           point: endLocation!,
//           width: 50,
//           height: 50,
//           alignment: Alignment.topCenter,
//           child: const Icon(
//             Icons.place,
//             size: 36,
//             color: Colors.red,
//           ),
//         ),
//       );
//     }
//
//     List<ll.LatLng> _buildRoutePoints(Journey journey) {
//       final points = <ll.LatLng>[];
//
//       // 1) Start
//       if (journey.startLocation != null) {
//         points.add(journey.startLocation!);
//       }
//
//       // 2) All check-in / check-out events in order
//       for (final e in journey.events) {
//         points.add(e.location);
//       }
//
//       // 3) End (if exists)
//       if (journey.endLocation != null) {
//         points.add(journey.endLocation!);
//       }
//
//       return points;
//     }
//
//
//     // 3) Check-in / Check-out markers from journey.events
//     // final events = journey?.events ?? [];
//     // for (final e in events) {
//     //   final isIn = e.type == 'IN';
//     //
//     //   markers.add(
//     //     Marker(
//     //       point: e.location,
//     //       width: 40,
//     //       height: 40,
//     //       alignment: Alignment.center,
//     //       child: Icon(
//     //         isIn ? Icons.login : Icons.logout, // or any icons you like
//     //         size: 24,
//     //         color: isIn ? Colors.green : Colors.orange,
//     //       ),
//     //     ),
//     //   );
//     // }
//
//     final events = journey?.events ?? [];
//     for (final e in events) {
//       final isIn = e.type == 'IN';
//
//       // Short label from address (you can customize this)
//       final String shortLabel;
//       if (e.address.contains(',')) {
//         shortLabel = e.address.split(',').first; // take first part, e.g. "Hossain garden"
//       } else {
//         shortLabel = e.address;
//       }
//
//       markers.add(
//         Marker(
//           point: e.location,
//           width: 120,
//           height: 80,
//           alignment: Alignment.topCenter,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 isIn ? Icons.login : Icons.logout,
//                 size: 26,
//                 color: isIn ? Colors.green : Colors.orange,
//               ),
//               const SizedBox(height: 2),
//               // Show label only for CHECK IN (as you asked)
//               if (isIn)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(4),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.15),
//                         blurRadius: 3,
//                         offset: const Offset(0, 1),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     shortLabel,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 9,
//                       color: Colors.black87,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       );
//     }
//     return markers;
//   }
//
//   List<ll.LatLng> _buildRoutePoints(Journey journey) {
//     final points = <ll.LatLng>[];
//
//     // 1) Start
//     if (journey.startLocation != null) {
//       points.add(journey.startLocation!);
//     }
//
//     // 2) All check-in / check-out events in order
//     for (final e in journey.events) {
//       points.add(e.location);
//     }
//
//     // 3) End (if exists)
//     if (journey.endLocation != null) {
//       points.add(journey.endLocation!);
//     }
//
//     return points;
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final routePoints = _buildRoutePoints(journey);
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Journey Map'),
//         backgroundColor: Colors.indigo,
//       ),
//       body: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: FlutterMap(
//                 mapController: _mapController,
//                 options: MapOptions(
//                   initialCenter: _mapCenter,
//                   initialZoom: 12,
//                   onTap: _handleMapTap,
//                   interactionOptions: const InteractionOptions(
//                     flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
//                   ),
//                 ),
//                 children: [
//                 TileLayer(
//                 urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 subdomains: const ['a', 'b', 'c'],
//                 userAgentPackageName: 'com.kendroo.gpslocator',
//               ),
//               MarkerLayer(
//                 markers: _buildMapMarkers(journey),
//               ),
//
//           if (routePoints.length >= 2)
//       PolylineLayer(
//     polylines: [
//     ll.Polyline(
//     points: routePoints,
//       color: Colors.indigo,
//       strokeWidth: 4.0,
//       pattern: const StrokePattern.dotted(),
//     ),
//     ],
//     ),
//
//     ],
//     ),
//     ),
//     ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
import '../model/journey_model.dart';

class JourneyMapScreen extends StatelessWidget {
  final Journey journey;
  final ll.LatLng? startLocation;
  final ll.LatLng? endLocation;

  JourneyMapScreen({
    super.key,
    required this.journey,
    this.startLocation,
    this.endLocation,
  });


  final MapController _mapController = MapController();


  final ll.LatLng _fallbackCenter = const ll.LatLng(23.780573, 90.279239);

  ll.LatLng get _mapCenter => startLocation ?? _fallbackCenter;

  void _handleMapTap(TapPosition _, ll.LatLng tappedPoint) {

  }

  List<Marker> _buildMapMarkers(Journey? journey, double screenWidth) {
    final markers = <Marker>[];

    final bool verySmall = screenWidth < 340;
    final bool small = screenWidth < 400;
    final bool large = screenWidth >= 600;


    final double startEndIconSize = small ? 30 : 36;
    final double eventIconSize = small ? 22 : 26;
    final double eventMarkerWidth = verySmall ? 90 : (small ? 110 : 120);
    final double eventMarkerHeight = verySmall ? 70 : 80;
    final double labelFontSize = verySmall ? 8 : (small ? 9 : 10);


    if (startLocation != null) {
      markers.add(
        Marker(
          point: startLocation!,
          width: 50,
          height: 50,
          alignment: Alignment.topCenter,
          child: Icon(
            Icons.flag,
            size: startEndIconSize,
            color: Colors.indigo,
          ),
        ),
      );
    }


    if (endLocation != null) {
      markers.add(
        Marker(
          point: endLocation!,
          width: 50,
          height: 50,
          alignment: Alignment.topCenter,
          child: Icon(
            Icons.place,
            size: startEndIconSize,
            color: Colors.red,
          ),
        ),
      );
    }


    final events = journey?.events ?? [];
    for (final e in events) {
      final isIn = e.type == 'IN';


      final String shortLabel;
      if (e.address.contains(',')) {
        shortLabel = e.address.split(',').first;
      } else {
        shortLabel = e.address;
      }

      markers.add(
        Marker(
          point: e.location,
          width: eventMarkerWidth,
          height: eventMarkerHeight,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isIn ? Icons.login : Icons.logout,
                size: eventIconSize,
                color: isIn ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 2),
              if (isIn)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    shortLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: labelFontSize,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
      for (final e in events) {
        final isIn = e.type == 'IN';
        final isAuto = (e.type == 'AUTO') || (e is JourneyCheckEvent && e.isAuto);

        final String shortLabel = e.address.split(',').first;

        markers.add(
          Marker(
            point: e.location,
            width: eventMarkerWidth,
            height: eventMarkerHeight,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAuto
                      ? Icons.push_pin   // ✅ pinned for auto
                      : (isIn ? Icons.login : Icons.logout),
                  size: eventIconSize,
                  color: isAuto
                      ? Colors.purple
                      : (isIn ? Colors.green : Colors.orange),
                ),
                const SizedBox(height: 2),
                // show label for auto OR for IN (your choice)
                if (isAuto || isIn)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      shortLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }


    }

    return markers;
  }


  List<ll.LatLng> _buildRoutePoints(Journey journey) {
    final points = <ll.LatLng>[];


    if (journey.startLocation != null) {
      points.add(journey.startLocation!);
    }


    for (final e in journey.events) {
      points.add(e.location);
    }

    if (journey.endLocation != null) {
      points.add(journey.endLocation!);
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = _buildRoutePoints(journey);

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final bool verySmall = width < 340;
    final bool small = width < 400;
    final bool tablet = width >= 600;

    final double horizontalPadding = verySmall ? 8 : 16;
    final double verticalPadding = small ? 6 : 8;
    final double borderRadius = small ? 12 : 16;
    final double initialZoom = tablet
        ? 13
        : (verySmall ? 11.5 : 12);
    final double polylineWidth = small ? 3.0 : 4.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Map'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: initialZoom,
              onTap: _handleMapTap,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.kendroo.gpslocator',
              ),
              MarkerLayer(
                markers: _buildMapMarkers(journey, width),
              ),
              if (routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    fm.Polyline(
                      points: routePoints,
                      color: Colors.indigo,
                      strokeWidth: polylineWidth,
                      pattern: const StrokePattern.dotted(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
