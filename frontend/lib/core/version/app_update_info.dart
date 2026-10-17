import '../constants/app_version_constants.dart';

/// Represents version control metadata fetched from Firebase Realtime Database.
class AppUpdateInfo {
  final String displayVersion;
  final String appUrl;
  final bool isMandatoryUpdate;
  final bool hasUpdate;

  const AppUpdateInfo({
    required this.displayVersion,
    required this.appUrl,
    required this.isMandatoryUpdate,
    required this.hasUpdate,
  });

  factory AppUpdateInfo.fromMap(Map<dynamic, dynamic> map) {
    // 1. Extract raw version as string (handles int 2, double 1.2, or string "1.2")
    final rawVersion = map['AppVersion'] ?? map['appVersion'];
    String versionStr = '1.0';
    if (rawVersion != null) {
      versionStr = rawVersion.toString().trim();
    }

    // 2. Extract download URL
    final rawUrl = (map['AppUrl'] ?? map['appUrl'] ?? '').toString().trim();

    // 3. Extract isMandatoryUpdate
    bool mandatory = false;
    final rawMandatory = map['isMandatoryUpdate'] ?? map['isMandatory'] ?? map['mandatory'];
    if (rawMandatory is bool) {
      mandatory = rawMandatory;
    } else if (rawMandatory is String) {
      mandatory = rawMandatory.toLowerCase() == 'true' || rawMandatory == '1';
    } else if (rawMandatory is num) {
      mandatory = rawMandatory == 1;
    }

    // 4. Compare with installed version
    final isNewer = _isVersionHigher(
      versionStr,
      '${AppVersionConstants.currentAppVersion}',
    );

    return AppUpdateInfo(
      displayVersion: versionStr,
      appUrl: rawUrl,
      isMandatoryUpdate: mandatory,
      hasUpdate: isNewer,
    );
  }

  /// Compares version strings supporting semantic (e.g. 1.2 vs 1, 2.0.1 vs 1.0.0)
  /// and numerical formats (1.2 > 1.0, 2 > 1).
  static bool _isVersionHigher(String latest, String current) {
    if (latest.isEmpty) return false;

    // Check direct numeric comparison first
    final lNum = double.tryParse(latest);
    final cNum = double.tryParse(current);
    if (lNum != null && cNum != null) {
      if (lNum > cNum) return true;
      if (lNum < cNum) return false;
    }

    // Check semantic segments: split by '.'
    final latestSegments = latest.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final currentSegments = current.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    final maxLen = latestSegments.length > currentSegments.length
        ? latestSegments.length
        : currentSegments.length;

    for (int i = 0; i < maxLen; i++) {
      final l = i < latestSegments.length ? latestSegments[i] : 0;
      final c = i < currentSegments.length ? currentSegments[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }

    return false;
  }
}
