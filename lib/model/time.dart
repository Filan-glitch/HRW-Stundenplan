class Time implements Comparable<Time> {
  final int hour;
  final int minute;

  int get totalMinutes => hour * 60 + minute;

  const Time(this.hour, this.minute);

  Time.parse(String string)
      : hour = int.parse(string.split(':')[0]),
        minute = int.parse(string.split(':')[1]);

  @override
  bool operator ==(Object other) {
    if (other is Time) {
      return hour == other.hour && minute == other.minute;
    }
    return false;
  }

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  int compareTo(Time other) {
    return totalMinutes.compareTo(other.totalMinutes);
  }
}
