import 'package:intl/intl.dart';

import 'date_time_calculator.dart';
import 'mode.dart';
import 'time.dart';
import 'weekday.dart';

final DateFormat dayFormat = DateFormat('dd/MM/yyyy');

enum EventMode {
  fromDB,
  edited,
  customEvent;

  int get dbValue {
    switch (this) {
      case EventMode.fromDB:
        return 0;
      case EventMode.edited:
        return 1;
      case EventMode.customEvent:
        return 2;
    }
  }

  static EventMode getByValue(int value) {
    switch (value) {
      case 0:
        return EventMode.fromDB;
      case 1:
        return EventMode.edited;
      case 2:
        return EventMode.customEvent;
      default:
        return EventMode.customEvent;
    }
  }
}

class Event implements Comparable<Event> {
  String get eventID =>
      '$abbreviation#${weekFrom == null ? '' : dayFormat.format(weekFrom!)}#${day.value}#${start.toString()}';
  String title;
  String abbreviation;
  Time start;
  Time end;
  String room;
  Weekday day;
  DateTime? weekFrom;
  EventMode mode;
  bool? collision;
  bool hidden;

  Mode get state {
    if (day.value == DateTime.now().weekday - 1) {
      final Time now = Time(DateTime.now().hour, DateTime.now().minute);
      if (start.compareTo(now) <= 0 && end.compareTo(now) >= 0) {
        return Mode.active;
      } else if (end.compareTo(now) <= 0) {
        return Mode.done;
      } else {
        return Mode.normal;
      }
    } else {
      return Mode.normal;
    }
  }

  Event({
    this.title = '',
    this.abbreviation = '',
    this.start = const Time(0, 0),
    this.end = const Time(0, 0),
    this.room = '',
    this.day = Weekday.monday,
    this.weekFrom,
    this.mode = EventMode.customEvent,
    this.collision,
    this.hidden = false,
  });

  Event.fromDB(Map<String, dynamic> data)
      : title = data['Title'] ?? '',
        abbreviation = data['Abbreviation'] ?? '',
        room = data['Room'] ?? '',
        day = Weekday.getByValue(int.parse(data['Weekday'] ?? '0')),
        weekFrom = data['WeekFrom'] == null
            ? null
            : cleanDate(dayFormat.parse(data['WeekFrom'])),
        start = Time(
          int.parse(data['Start']?.toString().split(':')[0] ?? '0'),
          int.parse(data['Start']?.toString().split(':')[1] ?? '0'),
        ),
        end = Time(
          int.parse(data['End']?.toString().split(':')[0] ?? '0'),
          int.parse(data['End']?.toString().split(':')[1] ?? '0'),
        ),
        mode = EventMode.getByValue(
          data['MODE'] ?? -1,
        ),
        hidden = data['HIDE_FLAG'] == 1;

  Map<String, dynamic> toDB() {
    return {
      'EventID': eventID,
      'Title': title,
      'Abbreviation': abbreviation,
      'Room': room,
      'Weekday': day.value.toString(),
      'Start': '${start.hour}:${start.minute}',
      'End': '${end.hour}:${end.minute}',
      'WeekFrom': weekFrom == null ? null : dayFormat.format(weekFrom!),
      'MODE': mode.dbValue,
    };
  }

  Event copyWith({
    String? title,
    String? abbreviation,
    Time? start,
    Time? end,
    String? room,
    Weekday? day,
    DateTime? weekFrom,
    EventMode? mode,
    bool? collision,
    bool? hidden,
  }) {
    return Event(
      title: title ?? this.title,
      abbreviation: abbreviation ?? this.abbreviation,
      start: start ?? this.start,
      end: end ?? this.end,
      room: room ?? this.room,
      day: day ?? this.day,
      weekFrom: weekFrom ?? this.weekFrom,
      mode: mode ?? this.mode,
      collision: collision ?? this.collision,
      hidden: hidden ?? this.hidden,
    );
  }

  @override
  String toString() {
    return '$title in $room von $start bis $end';
  }

  @override
  int compareTo(Event other) {
    if (weekFrom == null || other.weekFrom == null) {
      return 0;
    }

    return cleanDate(weekFrom!).add(Duration(days: day.value)).compareTo(
        cleanDate(other.weekFrom!).add(Duration(days: other.day.value)));
  }

  bool isCollidingWith(Event other) {
    return this.weekFrom == other.weekFrom &&
        this.day == other.day &&
        (start.compareTo(other.start) <= 0 && end.compareTo(other.start) > 0 ||
            start.compareTo(other.end) < 0 && end.compareTo(other.end) >= 0);
  }
}

void checkForCollisions(List<Event> events) {
  events.forEach((element) {
    element.collision = false;
  });
  events.asMap().forEach((i, event1) {
    events.sublist(i + 1).forEach((event2) {
      if (event1.isCollidingWith(event2)) {
        event1.collision = true;
        event2.collision = true;
      }
    });
  });
}
