DateTime getFirstDayOfMonth(DateTime dateTime) {
  return DateTime.utc(dateTime.year, dateTime.month, 1);
}

DateTime getFirstDayOfWeek(DateTime dateTime) {
  return DateTime.utc(dateTime.year, dateTime.month, dateTime.day)
      .subtract(Duration(days: dateTime.weekday - 1));
}

DateTime cleanDate(DateTime dateTime) {
  return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
}

bool isSameDay(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}
