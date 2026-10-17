import '../../core/utils/date_utils.dart';

extension DateExtensions on DateTime {
  String get toFormattedDate => AppDateUtils.formatDate(this);
}
