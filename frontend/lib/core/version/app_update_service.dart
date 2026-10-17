import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../constants/app_version_constants.dart';
import '../routing/app_router.dart';
import 'app_update_dialog.dart';
import 'app_update_info.dart';

class AppUpdateService {
  static final AppUpdateService instance = AppUpdateService._internal();
  AppUpdateService._internal();

  /// Primary Firebase RTDB REST endpoint
  static const String _rtdbRestUrl =
      'https://bharath-academy-1a1ce-default-rtdb.firebaseio.com/Shrinrityalaya.json';

  StreamSubscription<DatabaseEvent>? _realtimeSubscription;
  Timer? _activePollingTimer;
  String? _dismissedOptionalVersion;

  /// Starts listening to real-time database changes.
  /// If the version changes anywhere in the app at any time (on ANY page),
  /// the update popup is immediately presented to the user.
  void initializeRealtimeListener() {
    _realtimeSubscription?.cancel();
    _activePollingTimer?.cancel();

    debugPrint('[AppUpdateService] Initializing Realtime Update Listener...');

    // 1. Attach native Firebase Realtime Database WebSocket stream
    try {
      final ref = FirebaseDatabase.instance.ref(AppVersionConstants.firebaseNode);
      _realtimeSubscription = ref.onValue.listen(
        (DatabaseEvent event) {
          if (event.snapshot.exists && event.snapshot.value != null) {
            final value = event.snapshot.value;
            if (value is Map) {
              final updateInfo = AppUpdateInfo.fromMap(value);
              debugPrint('[AppUpdateService-SDK] Realtime event received: version=${updateInfo.displayVersion}, hasUpdate=${updateInfo.hasUpdate}');
              _handleRealtimeUpdate(updateInfo);
            }
          }
        },
        onError: (err) {
          debugPrint('[AppUpdateService-SDK] WebSocket stream notice: $err');
        },
      );
    } catch (e) {
      debugPrint('[AppUpdateService-SDK] Error attaching stream: $e');
    }

    // 2. Immediate REST fetch on startup (works instantly even before native SDK connects)
    _fetchFromRestApi().then((info) {
      if (info != null) {
        debugPrint('[AppUpdateService-REST] Initial check: DB version=${info.displayVersion}, hasUpdate=${info.hasUpdate}');
        if (info.hasUpdate) {
          _handleRealtimeUpdate(info);
        }
      }
    });

    // 3. Continuous 3-second polling timer running alongside WebSocket stream
    // Guarantees immediate detection on ANY page even during Hot Reload or network shifts
    _activePollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final info = await _fetchFromRestApi();
      if (info != null && info.hasUpdate) {
        _handleRealtimeUpdate(info);
      }
    });
  }

  /// Handles incoming update payload in real time on whichever page the user is viewing
  void _handleRealtimeUpdate(AppUpdateInfo updateInfo) {
    if (!updateInfo.hasUpdate) return;

    // If it's an optional update and the user already dismissed this specific version, skip
    if (!updateInfo.isMandatoryUpdate &&
        _dismissedOptionalVersion == updateInfo.displayVersion) {
      return;
    }

    _showDialogWhenReady(updateInfo);
  }

  /// Retries presenting the dialog until the current screen context is mounted and available
  void _showDialogWhenReady(AppUpdateInfo updateInfo, [int attempt = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        debugPrint('[AppUpdateService] Presenting update popup for version ${updateInfo.displayVersion} on active screen.');
        AppUpdateDialog.show(
          context,
          updateInfo,
          onProceed: () {
            _dismissedOptionalVersion = updateInfo.displayVersion;
          },
        );
      } else if (attempt < 15) {
        // If navigator is still rendering the first frame, retry in 300ms
        Future.delayed(const Duration(milliseconds: 300), () {
          _showDialogWhenReady(updateInfo, attempt + 1);
        });
      }
    });
  }

  /// Checks Firebase Realtime Database for new app updates manually.
  Future<AppUpdateInfo?> checkForUpdate() async {
    final info = await _fetchFromRestApi();
    if (info != null) return info;

    final sdkInfo = await _fetchFromFirebaseSdk();
    if (sdkInfo != null) return sdkInfo;

    return null;
  }

  /// Fetches from Firebase Database SDK
  Future<AppUpdateInfo?> _fetchFromFirebaseSdk() async {
    try {
      final ref = FirebaseDatabase.instance.ref(AppVersionConstants.firebaseNode);
      final snapshot = await ref.get().timeout(const Duration(seconds: 3));

      if (snapshot.exists && snapshot.value != null) {
        final value = snapshot.value;
        if (value is Map) {
          return AppUpdateInfo.fromMap(value);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Fallback fetch via REST API
  Future<AppUpdateInfo?> _fetchFromRestApi() async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ));

      final response = await dio.get(_rtdbRestUrl);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map) {
          return AppUpdateInfo.fromMap(data);
        }
      }
    } catch (e) {
      debugPrint('[AppUpdateService-REST] Check notice: $e');
    }
    return null;
  }

  void dispose() {
    _realtimeSubscription?.cancel();
    _activePollingTimer?.cancel();
    _realtimeSubscription = null;
    _activePollingTimer = null;
  }
}
