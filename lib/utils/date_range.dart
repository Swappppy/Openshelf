/// Day-based date helpers. Dates chosen in the app's pickers are local
/// midnights while stored timestamps may carry a time of day, so ranges are
/// compared by whole calendar days in local time.
class DayRange {
  DayRange._();

  /// Local midnight at the start of [date]'s calendar day.
  static DateTime startOfDay(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Local midnight at the start of the day after [date] (DST-safe).
  static DateTime startOfNextDay(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day + 1);
  }

  /// Whether [date] falls on any day from [start] to [end], both inclusive.
  static bool contains(DateTime date, DateTime start, DateTime end) =>
      !date.isBefore(startOfDay(start)) && date.isBefore(startOfNextDay(end));
}
