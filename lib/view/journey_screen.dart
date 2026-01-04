import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'package:flutter_map/flutter_map.dart' as ll;
import 'package:latlong2/latlong.dart' as ll;
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../model/journey_model.dart';
import '../provider/journey_provider.dart';
import 'background_location_task.dart';
import 'journey_map_screen.dart';


class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {

  final loc.Location _location = loc.Location();

  ll.LatLng? _startLocation;
  ll.LatLng? _endLocation;
  Timer? _autoTimer;
  DateTime? _lastLocationUpdateTime;


  bool isCheckedIn = false;
  String? _startAddress;
  String? _endAddress;

  double? _distanceInMeters;
  final ll.Distance distance = const ll.Distance();

  String _locationStatus = 'Initializing...';


  final ll.LatLng _fallbackCenter = const ll.LatLng(23.780573, 90.279239);
  StreamSubscription<loc.LocationData>? _locationSub;

  @override
  void initState() {
    super.initState();

    _checkLocationAndPermission();
    _listenLiveLocation();
  }

  void _listenLiveLocation() {
    _locationSub = _location.onLocationChanged.listen((loc.LocationData data) async {
      if (data.latitude != null && data.longitude != null) {
        final point = ll.LatLng(data.latitude!, data.longitude!);
        setState(() {
          _locationStatus = "Live location updated";
        });
      }
      final now = DateTime.now();

      if (_lastLocationUpdateTime == null ||
          now.difference(_lastLocationUpdateTime!).inMinutes >= 15) {

        _lastLocationUpdateTime = now;

        final point = ll.LatLng(
          data.latitude!,
          data.longitude!,
        );

        setState(() {
          _locationStatus = "Location updated at ${now.hour}:${now.minute}";
        });


        // saveLocation(point);
        // sendToServer(point);
        // updateMap(point);
      }
    });
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _stopAutoLocationUpdates();
    super.dispose();
  }


  Future<String> _getAddressFromLatLng(ll.LatLng point) async {
    try {
      final placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if ((p.street ?? '').isNotEmpty) p.street!,
          if ((p.locality ?? '').isNotEmpty)
            p.locality!
          else if ((p.subLocality ?? '').isNotEmpty)
            p.subLocality!,
          if ((p.country ?? '').isNotEmpty) p.country!,
        ];
        return parts.join(', ');
      }
      return '(${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})';
    } catch (_) {
      return '(${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})';
    }
  }

  void _handleCheckInOut() {
    setState(() {
      isCheckedIn = !isCheckedIn;
    });

    if (isCheckedIn) {
      _setStartFromDevice();

      print("Checked in");
    } else {
      _onEndJourney();


    }
  }


  Future<List<(String, ll.LatLng)>> _forwardGeocode(String query) async {
    final results = await locationFromAddress(query);
    final limited = results.take(5).toList();
    final List<(String, ll.LatLng)> items = [];
    for (final r in limited) {
      final point = ll.LatLng(r.latitude, r.longitude);
      final nice = await _getAddressFromLatLng(point);
      items.add((nice, point));
    }
    return items;
  }

  Future<void> _checkLocationAndPermission() async {
    setState(() => _locationStatus = 'Checking permissions and services...');

    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() => _locationStatus = 'Location Service is disabled. Please enable it.');
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        setState(() => _locationStatus = 'Location Permission is denied.');
        return;
      }
    }

    setState(() => _locationStatus = 'Ready. Set start location by search.');
  }



  List<Marker> _buildMapMarkers(Journey? journey) {
    final markers = <Marker>[];

    if (_startLocation != null) {
      markers.add(
        Marker(
          point: _startLocation!,
          width: 50,
          height: 50,
          alignment: Alignment.topCenter,
          child: const Icon(
            Icons.flag,
            size: 36,
            color: Colors.indigo,
          ),
        ),
      );
    }


    if (_endLocation != null) {
      markers.add(
        Marker(
          point: _endLocation!,
          width: 50,
          height: 50,
          alignment: Alignment.topCenter,
          child: const Icon(
            Icons.place,
            size: 36,
            color: Colors.red,
          ),
        ),
      );
    }

    final events = journey?.events ?? [];
    for (final e in events) {
      final isIn = e.type == 'IN';

      markers.add(
        Marker(
          point: e.location,
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            isIn ? Icons.login : Icons.logout,
            size: 24,
            color: isIn ? Colors.green : Colors.orange,
          ),
        ),
      );
    }

    return markers;
  }

  void _startAutoLocationUpdates() {
    _autoTimer?.cancel();

    _autoTimer = Timer.periodic(const Duration(minutes: 15), (_) async {
      final journeyProvider = context.read<JourneyProvider>();


      if (_startLocation == null || _startAddress == null) return;
      if (!mounted) return;

      final data = await _location.getLocation();
      if (data.latitude == null || data.longitude == null) return;

      final point = ll.LatLng(data.latitude!, data.longitude!);
      final address = await _getAddressFromLatLng(point);

      journeyProvider.addCheckEvent(
        type: 'AUTO',
        location: point,
        address: address,
        isAuto: true,
      );

      if (!mounted) return;
      setState(() {
        _locationStatus = "Auto updated location (15 min)";
      });
    });
  }

  void _stopAutoLocationUpdates() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  Future<void> _setStartFromDevice() async {
    final journeyProvider = context.read<JourneyProvider>();


    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable Location Service.')),
        );
        return;
      }
    }

    loc.PermissionStatus permission = await _location.hasPermission();
    if (permission == loc.PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != loc.PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission required.')),
        );
        return;
      }
    }

    final loc.LocationData data = await _location.getLocation();
    if (data.latitude == null || data.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get current location for START.')),
      );
      return;
    }

    final ll.LatLng point = ll.LatLng(data.latitude!, data.longitude!);
    final address = await _getAddressFromLatLng(point);

    setState(() {
      _startLocation = point;
      _startAddress = address;
      _locationStatus = 'Start location set from current GPS.';
    });


    journeyProvider.initJourney(
      startLocation: point,
      startAddress: address,
    );
    _startAutoLocationUpdates();
    await FlutterForegroundTask.startService(
      notificationTitle: 'Journey in progress',
      notificationText: 'Location updates every 15 minutes',
      callback: startCallback,
    );

    debugPrint('START set at: $point ($address)');
  }


  void _calculateDistance() {
    if (_startLocation != null && _endLocation != null) {
      final d = distance(_startLocation!, _endLocation!);
      setState(() {
        _distanceInMeters = d;
      });
    } else {
      setState(() => _distanceInMeters = null);
    }
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '—';
    if (meters < 1000) return '${meters.toStringAsFixed(1)} meters';
    return '${(meters / 1000).toStringAsFixed(2)} kilometers';
  }

  ll.LatLng get _mapCenter => _startLocation ?? _fallbackCenter;


  void _onEndJourney() async {
    _stopAutoLocationUpdates();
    await FlutterForegroundTask.stopService();

    final journeyProvider = context.read<JourneyProvider>();

    if (_startLocation == null || _startAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set START location (via search) first.')),
      );
      return;
    }

    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable Location Service.')),
        );
        return;
      }
    }

    loc.PermissionStatus permission = await _location.hasPermission();
    if (permission == loc.PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != loc.PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission required.')),
        );
        return;
      }
    }

    final loc.LocationData data = await _location.getLocation();
    if (data.latitude == null || data.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get current location for END.')),
      );
      return;
    }

    final ll.LatLng point = ll.LatLng(data.latitude!, data.longitude!);
    final address = await _getAddressFromLatLng(point);

    debugPrint('END JOURNEY at: $point ($address) from START: $_startLocation');

    setState(() {
      _endLocation = point;
      _endAddress = address;
      _locationStatus = 'Journey ended at current GPS location.';
    });

    _calculateDistance();



    journeyProvider.addCheckEvent(
      type: 'OUT',
      location: point,
      address: address,
    );


    journeyProvider.completeJourney(
      endLocation: point,
      endAddress: address,
      distanceInMeters: _distanceInMeters,
    );


    try {
      await journeyProvider.saveCurrentJourney();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journey saved successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save journey.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    final journeyProvider = context.watch<JourneyProvider>();
    final currentJourney = journeyProvider.current;
    final isSaving = journeyProvider.isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add location'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              children: [
                _buildInfoCard(currentJourney),
                const SizedBox(height:6),
                Text(
                  _locationStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
                if (isSaving) ...[
                  const SizedBox(height: 6),
                  const LinearProgressIndicator(minHeight: 2),
                ],
              ],
            ),
          ),

          Padding(
          padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 360 ? 10 : 16,
          vertical: MediaQuery.of(context).size.width < 360 ? 4 : 5,
          ),
          child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.width < 380
          ? 45
              : MediaQuery.of(context).size.width < 600
          ? 50
              : 60,
          child: ElevatedButton.icon(
          onPressed: () {
    if (currentJourney == null) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('No journey data to show on map.'),
    ),
    );
    return;
    }

    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) => JourneyMapScreen(
    journey: currentJourney,
    startLocation: _startLocation,
    endLocation: _endLocation,
    ),
    ),
    );
    },

    icon: Icon(
    Icons.map,
    size: MediaQuery.of(context).size.width < 380
    ? 18
        : MediaQuery.of(context).size.width < 600
    ? 22
        : 26, // responsive icon size
    ),

    label: Text(
    'VIEW MAP',
    style: TextStyle(
    fontSize: MediaQuery.of(context).size.width < 380
    ? 13
        : MediaQuery.of(context).size.width < 600
    ? 15
        : 18, // responsive text
    fontWeight: FontWeight.w600,
    ),
    ),

    style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 0),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    ),
    ),
    ),
    ),


SizedBox(height: 20,),
    Padding(
    padding: EdgeInsets.fromLTRB(
    MediaQuery.of(context).size.width < 360 ? 8 : 10,   // left
    0,
    MediaQuery.of(context).size.width < 360 ? 12 : 16,  // right
    MediaQuery.of(context).size.width < 400 ? 16 : 20,  // bottom
    ),
    child: Builder(
    builder: (context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmall = width < 380;
    final double buttonHeight = isSmall ? 44 : 50;
    final double primaryFontSize = isSmall ? 13 : 14;
    final double endFontSize = isSmall ? 13 : 14.5;
    final double gapLarge = isSmall ? 8 : 12;
    final double gapSmall = isSmall ? 6 : 8;

    return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    Row(
    children: [
    Expanded(
    child: SizedBox(
      height: buttonHeight,
      child: ElevatedButton.icon(
        onPressed: _handleCheckInOut,
        icon: Icon(
          isCheckedIn ? Icons.logout : Icons.search,
          size: isSmall ? 18 : 20,
        ),
        label: Text(
          isCheckedIn ? 'Check Out' : 'Check In',
          style: TextStyle(
            fontSize: primaryFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isCheckedIn ? Colors.red : Colors.indigo,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ),
      ),
      ],
      ),


      SizedBox(height: gapLarge),



    ],
    );
    },
    ),
    )


    ],
      ),
    );
  }


  Widget _buildInfoCard(Journey? journey) {
    final distanceText = _formatDistance(_distanceInMeters);
    Color distanceColor = _distanceInMeters != null
        ? Colors.indigo
        : (_startLocation != null ? Colors.orange.shade700 : Colors.grey);

    final events = journey?.events ?? [];


    final width = MediaQuery.of(context).size.width;
    final bool isVerySmall = width < 340;
    final bool isSmall = width < 400;
    final bool isTablet = width >= 600;

    final double cardPadding = isVerySmall ? 12 : (isSmall ? 14 : 18);
    final double titleFontSize = isVerySmall ? 13.5 : (isSmall ? 14.5 : 16);
    final double bodyFontSize = isVerySmall ? 12.5 : (isSmall ? 13.5 : 15);
    final double historyHeight = isVerySmall
        ? 100
        : (isSmall ? 120 : (isTablet ? 180 : 140));

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildLocationDetail(
                    'Start Location:',
                    _startAddress,
                    Icons.flag,
                    Colors.indigo,
                    titleFontSize: titleFontSize,
                    bodyFontSize: bodyFontSize,
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            _buildLocationDetail(
              'End Location:',
              _endAddress,
              Icons.place,
              Colors.red,
              titleFontSize: titleFontSize,
              bodyFontSize: bodyFontSize,
            ),

            const Divider(height: 20),

            if (events.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Check-in / Check-out History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 13.5 : 15,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: historyHeight,
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryRow(
                      events[index],
                      compact: isSmall || isVerySmall,
                    );
                  },
                ),
              ),
            ] else ...[
              Text(
                'No check-in / check-out yet.',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                ),
              ),
            ],

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }


  Widget _buildHistoryRow(
      JourneyCheckEvent e, {
        bool compact = false,
      }) {
    final isIn = e.type == 'IN';
    final typeColor = isIn ? Colors.green : Colors.orange;
    final typeLabel = isIn ? 'CHECK IN' : 'CHECK OUT';

    final time = e.timestamp.toLocal();
    final dateStr =
        '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';


    final width = MediaQuery.of(context).size.width;
    final bool verySmall = width < 340;
    final bool small = width < 400;

    final double dateFontSize =
    compact || small ? 11.0 : 12.0;
    final double addrFontSize = compact || small ? 11.0 : 12.0;
    final double chipFontSize = compact || small ? 10.0 : 11.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            // child: Text(
            //   typeLabel,
            //   style: TextStyle(
            //     color: typeColor,
            //     fontWeight: FontWeight.bold,
            //     fontSize: chipFontSize,
            //   ),
            // ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: dateFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  e.address,
                  maxLines: verySmall ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: addrFontSize,
                    color: Colors.black87,
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLocationDetail(
      String label,
      String? address,
      IconData icon,
      Color iconColor, {
        required double titleFontSize,
        required double bodyFontSize,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28.0, top: 4.0),
          child: Text(
            address ?? 'Not set yet…',
            style: TextStyle(
              fontSize: bodyFontSize,
              fontStyle: address == null ? FontStyle.italic : FontStyle.normal,
              color: address == null ? Colors.grey.shade600 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
