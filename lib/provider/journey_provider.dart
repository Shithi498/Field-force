
import 'package:flutter/foundation.dart';
import '../model/journey_model.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../repo/journey_repository.dart';


class JourneyProvider extends ChangeNotifier {
  final JourneyRepository _repository;

  JourneyProvider(this._repository);

  Journey? _current;
  List<Journey> _history = [];
  bool _isSaving = false;
  String? _error;

  Journey? get current => _current;
  List<Journey> get history => List.unmodifiable(_history);
  bool get isSaving => _isSaving;
  String? get error => _error;


  void initJourney({
    required ll.LatLng startLocation,
    required String startAddress,
  }) {
    _current = Journey(
      startLocation: startLocation,
      startAddress: startAddress,
      endLocation: null,
      endAddress: null,
      distanceInMeters: null,
      events: [],
      startedAt: DateTime.now(),
      endedAt: null,
    );
    _error = null;
    notifyListeners();
  }


  // void addCheckEvent({
  //   required String type,
  //   required ll.LatLng location,
  //   required String address,
  // }) {
  //   if (_current == null) {
  //
  //     return;
  //   }
  //
  //   final event = JourneyCheckEvent(
  //     type: type,
  //     timestamp: DateTime.now(),
  //     location: location,
  //     address: address,
  //   );
  //
  //   final updatedEvents = [event, ..._current!.events];
  //
  //   _current = _current!.copyWith(events: updatedEvents);
  //   notifyListeners();
  // }
  void addCheckEvent({
    required String type,
    required ll.LatLng location,
    required String address,
    bool isAuto = false,
  }) {
    _current?.events.add(
      JourneyCheckEvent(
        type: type,
        location: location,
        address: address,
        timestamp: DateTime.now(),
        isAuto: isAuto,
      ),
    );
    notifyListeners();
  }


  void completeJourney({
    required ll.LatLng endLocation,
    required String endAddress,
    double? distanceInMeters,
  }) {
    if (_current == null) return;

    _current = _current!.copyWith(
      endLocation: endLocation,
      endAddress: endAddress,
      distanceInMeters: distanceInMeters,
      endedAt: DateTime.now(),
    );
    notifyListeners();
  }


  Future<void> saveCurrentJourney() async {
    if (_current == null) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final saved = await _repository.saveJourney(_current!);
      _history.insert(0, saved);
      _current = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error saving journey: $e');
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }


  Future<void> loadHistory() async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final journeys = await _repository.fetchJourneys();
      _history = journeys;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }


  void clearError() {
    _error = null;
    notifyListeners();
  }
}
