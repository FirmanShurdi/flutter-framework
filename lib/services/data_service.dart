import 'dart:async';
import 'dart:convert';
import 'preference_service.dart';

class DataService {
  final PreferenceService _prefService = PreferenceService();

  // Simulate an API call
  Future<Map<String, dynamic>> fetchParkingStats({bool forceError = false}) async {
    // Artificial delay
    await Future.delayed(const Duration(seconds: 1));

    if (forceError) {
      // Return from cache if API "fails"
      final cached = await _prefService.getCachedData();
      if (cached != null) {
        return {
          'data': jsonDecode(cached),
          'source': 'Cached Data',
          'isError': false
        };
      } else {
        return {
          'data': null,
          'source': 'No Data',
          'isError': true,
          'message': 'API Gagal & Tidak ada Cache'
        };
      }
    }

    // Success case - Simulated Data
    final data = {
      'total_slots': 150,
      'available_slots': 42,
      'occupied_slots': 108,
      'last_update': DateTime.now().toIso8601String(),
    };

    // Save to cache
    await _prefService.saveCacheData(jsonEncode(data));

    return {
      'data': data,
      'source': 'Online Data',
      'isError': false
    };
  }
}
