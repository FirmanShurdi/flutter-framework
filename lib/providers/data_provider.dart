import 'package:flutter/material.dart';
import '../services/data_service.dart';

class DataProvider extends ChangeNotifier {
  final DataService _service = DataService();

  Map<String, dynamic>? _parkingData;
  Map<String, dynamic>? get parkingData => _parkingData;

  String _dataSource = 'No Data';
  String get dataSource => _dataSource;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _simulateError = false;
  bool get simulateError => _simulateError;

  void toggleSimulateError() {
    _simulateError = !_simulateError;
    notifyListeners();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    final result = await _service.fetchParkingStats(forceError: _simulateError);
    
    _parkingData = result['data'];
    _dataSource = result['source'];
    _isLoading = false;
    notifyListeners();
  }
}
