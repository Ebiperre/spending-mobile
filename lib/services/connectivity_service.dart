import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Connection status enum
enum ConnectionStatus {
  online,
  offline,
  unknown,
}

/// Service for monitoring network connectivity
class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectionStatus _status = ConnectionStatus.unknown;
  bool _isInitialized = false;

  /// Current connection status
  ConnectionStatus get status => _status;

  /// Check if online
  bool get isOnline => _status == ConnectionStatus.online;

  /// Check if offline
  bool get isOffline => _status == ConnectionStatus.offline;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Stream controller for status changes
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  /// Stream for listening to connectivity changes
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  /// Callbacks for when connectivity changes
  final List<VoidCallback> _onOnlineCallbacks = [];
  final List<VoidCallback> _onOfflineCallbacks = [];

  /// Initialize connectivity monitoring
  Future<void> init() async {
    if (_isInitialized) return;

    // Check initial status
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results, isInitial: true);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });

    _isInitialized = true;
  }

  /// Update connection status based on connectivity results
  void _updateStatus(List<ConnectivityResult> results, {bool isInitial = false}) {
    ConnectionStatus newStatus;

    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      newStatus = ConnectionStatus.offline;
    } else if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.ethernet)) {
      newStatus = ConnectionStatus.online;
    } else {
      newStatus = ConnectionStatus.unknown;
    }

    final wasOffline = _status == ConnectionStatus.offline;
    final wasOnline = _status == ConnectionStatus.online;

    if (_status != newStatus || isInitial) {
      _status = newStatus;
      _statusController.add(_status);
      notifyListeners();

      // Trigger callbacks
      if (newStatus == ConnectionStatus.online && (wasOffline || isInitial)) {
        _triggerOnlineCallbacks();
      } else if (newStatus == ConnectionStatus.offline && (wasOnline || isInitial)) {
        _triggerOfflineCallbacks();
      }

      debugPrint('Connectivity changed: $newStatus');
    }
  }

  /// Register callback for when device comes online
  void onOnline(VoidCallback callback) {
    _onOnlineCallbacks.add(callback);
  }

  /// Register callback for when device goes offline
  void onOffline(VoidCallback callback) {
    _onOfflineCallbacks.add(callback);
  }

  /// Remove online callback
  void removeOnlineCallback(VoidCallback callback) {
    _onOnlineCallbacks.remove(callback);
  }

  /// Remove offline callback
  void removeOfflineCallback(VoidCallback callback) {
    _onOfflineCallbacks.remove(callback);
  }

  /// Trigger all online callbacks
  void _triggerOnlineCallbacks() {
    for (final callback in _onOnlineCallbacks) {
      callback();
    }
  }

  /// Trigger all offline callbacks
  void _triggerOfflineCallbacks() {
    for (final callback in _onOfflineCallbacks) {
      callback();
    }
  }

  /// Force check connectivity (useful for manual refresh)
  Future<ConnectionStatus> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
    return _status;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
    _onOnlineCallbacks.clear();
    _onOfflineCallbacks.clear();
    super.dispose();
  }
}
